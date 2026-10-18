import CoreAI
import Foundation
import Metal

// Does Core AI observe Swift task cancellation? Each case runs in a child task
// that cancels itself before its first Core AI call, so any cooperative check
// (Task.isCancelled, checkCancellation, cancellation handlers) would be visible.
// A case reports whether it completed normally with exact x+x bytes.

struct OracleError: Error { let message: String }

let values: [Float] = [1, -2, 0, 0.5, 100, -0.25]
let expected: [Float] = [2, -4, 0, 1, 200, -0.5]

func input() -> NDArray {
    var array = NDArray(shape: [2, 3], scalarType: .float32)
    array.mutableRawView().withUnsafeMutableBytes { destination, _, _ in
        values.withUnsafeBytes { destination.copyMemory(from: $0.baseAddress!, byteCount: $0.count) }
    }
    return array
}

func exact(_ array: NDArray) -> Bool {
    guard array.shape == [2, 3], array.scalarType == .float32 else { return false }
    let actual: [Float] = array.rawView().withUnsafeBytes { start, _, _ in
        Array(UnsafeBufferPointer(start: start.assumingMemoryBound(to: Float.self), count: 6))
    }
    return actual.withUnsafeBytes { Data($0) } == expected.withUnsafeBytes { Data($0) }
}

func cancelledCase(_ body: @escaping @Sendable () async throws -> Bool) async -> [String: Any] {
    let task = Task { () async throws -> [String: Any] in
        withUnsafeCurrentTask { $0!.cancel() }
        let observed = Task.isCancelled
        let started = Date()
        let matched = try await body()
        return ["cancelled_before_call": observed, "exact": matched,
                "still_cancelled_after": Task.isCancelled,
                "elapsed_ms": Date().timeIntervalSince(started) * 1000]
    }
    do {
        var row = try await task.value
        row["outcome"] = "completed"
        return row
    } catch {
        return ["outcome": "threw", "error_type": _typeName(type(of: error), qualified: true),
                "is_cancellation_error": error is CancellationError,
                "description": String(describing: error)]
    }
}

func load(_ path: String, _ options: SpecializationOptions) async throws -> InferenceFunction {
    let model = try await AIModel(contentsOf: URL(fileURLWithPath: path), options: options)
    guard let function = try model.loadFunction(named: "main") else { throw OracleError(message: "missing main") }
    return function
}

@main struct CancellationOracle {
    static func main() async throws {
        guard CommandLine.arguments.count == 2 else {
            print("usage: cancellation-oracle X_PLUS_X_ASSET")
            exit(2)
        }
        let path = CommandLine.arguments[1]
        var report: [String: Any] = [:]
        var allCompleted = true
        for (name, options) in [("cpu_only", SpecializationOptions.cpuOnly),
                                ("gpu_preferred", SpecializationOptions(preferredComputeUnitKind: .gpu))] {
            var rows: [String: Any] = [:]
            rows["load"] = await cancelledCase {
                let function = try await load(path, options)
                var outputs = try await function.run(inputs: ["x": input()])
                guard let array = outputs.remove("y")?.ndArray else { return false }
                return exact(array)
            }
            let function = try await load(path, options)
            rows["run"] = await cancelledCase {
                var outputs = try await function.run(inputs: ["x": input()])
                guard let array = outputs.remove("y")?.ndArray else { return false }
                return exact(array)
            }
            rows["run_repeated_100"] = await cancelledCase {
                for _ in 0..<100 {
                    var outputs = try await function.run(inputs: ["x": input()])
                    guard let array = outputs.remove("y")?.ndArray, exact(array) else { return false }
                }
                return true
            }
            rows["stream_encode_fence_read"] = await cancelledCase {
                guard let device = MTLCreateSystemDefaultDevice(), let queue = device.makeCommandQueue() else {
                    throw OracleError(message: "no Metal queue")
                }
                let stream = ComputeStream(commandQueue: queue)
                var outputs = try function.encode(inputs: ["x": InferenceFunction.AsyncValue(input())], to: stream)
                await stream.currentWorkCompleted()
                guard let value = outputs.removeValue(forKey: "y"), let array = try await value.ndArray else {
                    return false
                }
                await stream.currentWorkCompleted()
                return exact(array)
            }
            if rows.values.contains(where: { ($0 as? [String: Any])?["exact"] as? Bool != true }) {
                allCompleted = false
            }
            report[name] = rows
        }
        report["all_cancelled_cases_completed_exactly"] = allCompleted
        let bytes = try JSONSerialization.data(withJSONObject: report, options: [.sortedKeys, .prettyPrinted])
        print(String(decoding: bytes, as: UTF8.self))
    }
}
