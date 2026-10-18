import CoreAI
import Foundation
import Metal

// Records compute-unit availability and the options each preference produces,
// then runs the x+x fixture through plain run and stream encode per preference.

let values: [Float] = [1, -2, 0, 0.5, 100, -0.25]
let expected: [Float] = [2, -4, 0, 1, 200, -0.5]

func name(_ kind: ComputeUnitKind) -> String {
    switch kind {
    case .cpu: "cpu"
    case .gpu: "gpu"
    case .neuralEngine: "neural_engine"
    @unknown default: "unknown"
    }
}

func describe(_ options: SpecializationOptions) -> [String: Any] {
    ["allowed": options.allowedComputeUnitKinds.map(name).sorted(),
     "preferred": options.preferredComputeUnitKind.map(name) ?? NSNull(),
     "expect_frequent_reshapes": options.expectFrequentReshapes]
}

func input() -> NDArray {
    var array = NDArray(shape: [2, 3], scalarType: .float32)
    array.mutableRawView().withUnsafeMutableBytes { destination, _, _ in
        values.withUnsafeBytes { destination.copyMemory(from: $0.baseAddress!, byteCount: $0.count) }
    }
    return array
}

func floats(_ array: NDArray) -> [Float] {
    array.rawView().withUnsafeBytes { start, _, _ in
        Array(UnsafeBufferPointer(start: start.assumingMemoryBound(to: Float.self), count: 6))
    }
}

func attempt(_ body: () async throws -> [Float]) async -> [String: Any] {
    do {
        let actual = try await body()
        return ["outcome": "completed", "values": actual, "exact": actual == expected]
    } catch {
        return ["outcome": "threw", "error_type": _typeName(type(of: error), qualified: true),
                "description": String(describing: error)]
    }
}

@main struct ComputeUnitsOracle {
    static func main() async throws {
        let path = CommandLine.arguments[1]
        var report: [String: Any] = [
            "available": ComputeUnitKind.availableKinds.map(name).sorted(),
            "device_architecture": AIModel.deviceArchitectureName,
            "default": describe(.default),
            "cpu_only": describe(.cpuOnly),
        ]
        var preferences: [String: Any] = [:]
        for kind in [ComputeUnitKind.cpu, .gpu, .neuralEngine] {
            let options = SpecializationOptions(preferredComputeUnitKind: kind)
            var row = describe(options)
            do {
                let model = try await AIModel(contentsOf: URL(fileURLWithPath: path), options: options)
                let function = try model.loadFunction(named: "main")!
                row["run"] = await attempt {
                    var outputs = try await function.run(inputs: ["x": input()])
                    return floats(outputs.remove("y")!.ndArray!)
                }
                row["stream"] = await attempt {
                    let queue = MTLCreateSystemDefaultDevice()!.makeCommandQueue()!
                    let stream = ComputeStream(commandQueue: queue)
                    var outputs = try function.encode(inputs: ["x": InferenceFunction.AsyncValue(input())], to: stream)
                    await stream.currentWorkCompleted()
                    let array = try await outputs.removeValue(forKey: "y")!.ndArray!
                    await stream.currentWorkCompleted()
                    return floats(array)
                }
            } catch {
                row["load_error"] = String(describing: error)
            }
            preferences[name(kind)] = row
        }
        report["preferred"] = preferences
        let bytes = try JSONSerialization.data(withJSONObject: report, options: [.sortedKeys, .prettyPrinted])
        print(String(decoding: bytes, as: UTF8.self))
    }
}
