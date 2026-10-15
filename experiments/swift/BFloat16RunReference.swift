import CoreAI
import CryptoKit
import Foundation

// Development-only independent Swift oracle. Never linked by Corsairs.
struct BF16OracleError: Error { let message: String }
struct BF16TensorFixture: Decodable {
    let file: String
    let shape: [Int]
    let dtype: String
}
struct BF16Step: Decodable {
    let inputs: [String: BF16TensorFixture]
    let outputs: [String: BF16TensorFixture]
    let state_after: [String: BF16TensorFixture]?
}
struct BF16Case: Decodable {
    let name: String
    let model: String
    let function: String
    let steps: [BF16Step]
    let state: [String: BF16TensorFixture]?
}
struct BF16Manifest: Decodable { let cases: [BF16Case] }

func require(_ value: Bool, _ message: String) throws {
    if !value { throw BF16OracleError(message: message) }
}
func digest(_ data: Data) -> String {
    SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
}
func rawBytes(_ array: borrowing NDArray) throws -> Data {
    try require(array.scalarType == .bfloat16, "output is not native BF16")
    try require(array.interleaveLayout == nil, "interleave unsupported by test oracle")
    let shape = array.shape, strides = array.strides
    try require(strides.count == shape.count && strides.allSatisfy { $0 >= 0 }, "invalid strides")
    let count = shape.reduce(1, *)
    if count == 0 { return Data() }
    return array.rawView().withUnsafeBytes { pointer, _, _ in
        var data = Data(count: count * 2)
        data.withUnsafeMutableBytes { destination in
            var index = [Int](repeating: 0, count: shape.count)
            for element in 0..<count {
                let offset = zip(index, strides).reduce(0) { $0 + $1.0 * $1.1 }
                destination.baseAddress!.advanced(by: element * 2)
                    .copyMemory(from: pointer.advanced(by: offset * 2), byteCount: 2)
                for axis in shape.indices.reversed() {
                    index[axis] += 1
                    if index[axis] < shape[axis] { break }
                    index[axis] = 0
                }
            }
        }
        return data
    }
}
func tensor(_ fixture: BF16TensorFixture, in directory: URL) throws -> NDArray {
    try require(fixture.dtype == "bfloat16", "fixture dtype")
    let data = try Data(contentsOf: directory.appendingPathComponent(fixture.file))
    try require(data.count == fixture.shape.reduce(1, *) * 2, "fixture extent")
    var array = NDArray(shape: fixture.shape, scalarType: .bfloat16)
    if !data.isEmpty {
        array.mutableRawView().withUnsafeMutableBytes { destination, _, _ in
            data.withUnsafeBytes { source in
                destination.copyMemory(from: source.baseAddress!, byteCount: source.count)
            }
        }
    }
    try require(try rawBytes(array) == data, "fixture raw copy")
    return array
}

@main struct BF16Oracle {
    static func main() async throws {
        guard CommandLine.arguments.count == 3 else {
            print("usage: bfloat16-oracle FIXTURE_DIRECTORY OUTPUT_DIRECTORY")
            exit(2)
        }
        let directory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        let outputDirectory = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: true)
        try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        do {
            // Cover all bit patterns by raw storage only, including NaN payloads.
            var allBits = Data(capacity: 65536 * 2)
            for bits in UInt32(0)..<65536 {
                allBits.append(UInt8(truncatingIfNeeded: bits))
                allBits.append(UInt8(truncatingIfNeeded: bits >> 8))
            }
            let retained = try Data(contentsOf: directory.appendingPathComponent("all-encodings.bin"))
            try require(allBits == retained, "all-encoding fixture identity")
            var array = NDArray(shape: [65536], scalarType: .bfloat16)
            array.mutableRawView().withUnsafeMutableBytes { destination, _, _ in
                allBits.withUnsafeBytes { source in
                    destination.copyMemory(from: source.baseAddress!, byteCount: source.count)
                }
            }
            let copied = try rawBytes(array)
            try require(copied == allBits, "all 65536 BF16 encodings")
            try require(array.scalarType != .float16, "BF16 must differ from Float16")
            try copied.write(to: outputDirectory.appendingPathComponent("all-encodings.bin"))
            let manifest = try JSONDecoder().decode(BF16Manifest.self,
                from: Data(contentsOf: directory.appendingPathComponent("manifest.json")))
            var records: [[String: Any]] = []
            for backend in ["cpu", "gpu-preferred"] {
                for testCase in manifest.cases {
                    let options: SpecializationOptions = backend == "cpu" ? .cpuOnly : SpecializationOptions(preferredComputeUnitKind: .gpu)
                    let model = try await AIModel(contentsOf: directory.appendingPathComponent(testCase.model), options: options)
                    guard let function = try model.loadFunction(named: testCase.function) else {
                        throw BF16OracleError(message: "missing function")
                    }
                    var state = NDArray(shape: [2, 3], scalarType: .bfloat16)
                    if let fixture = testCase.state?["accumulator"] {
                        state = try tensor(fixture, in: directory)
                    }
                    for (index, step) in testCase.steps.enumerated() {
                        var inputs: [String: NDArray] = [:]
                        for (name, fixture) in step.inputs { inputs[name] = try tensor(fixture, in: directory) }
                        var outputs: InferenceFunction.Outputs
                        if testCase.state != nil {
                            var states = InferenceFunction.MutableViews()
                            states.insert(&state, for: "accumulator")
                            outputs = try await function.run(inputs: inputs, states: states)
                        } else {
                            outputs = try await function.run(inputs: inputs)
                        }
                        guard let value = outputs.remove("y"), let result = value.ndArray,
                              let expected = step.outputs["y"] else {
                            throw BF16OracleError(message: "missing NDArray y")
                        }
                        let bytes = try rawBytes(result)
                        let expectedBytes = try Data(contentsOf: directory.appendingPathComponent(expected.file))
                        try require(bytes == expectedBytes && result.shape == expected.shape, "arithmetic output mismatch")
                        let label = "\(backend)-\(testCase.name)-\(index)"
                        try bytes.write(to: outputDirectory.appendingPathComponent(label + "-y.bin"))
                        var record: [String: Any] = ["backend": backend, "case": testCase.name, "step": index,
                            "dtype": "bfloat16", "shape": result.shape, "strides": result.strides,
                            "exact_bytes": true, "sha256": digest(bytes)]
                        if let expected = step.state_after?["accumulator"] {
                            let stateBytes = try rawBytes(state)
                            let expectedBytes = try Data(contentsOf: directory.appendingPathComponent(expected.file))
                            try require(stateBytes == expectedBytes, "state output mismatch")
                            try stateBytes.write(to: outputDirectory.appendingPathComponent(label + "-state.bin"))
                            record["state_sha256"] = digest(stateBytes)
                        }
                        records.append(record)
                    }
                }
            }
            let report: [String: Any] = ["passed": true, "all_encodings": 65536,
                "raw_roundtrip_sha256": digest(copied), "bfloat16_distinct_from_float16": true,
                "records": records, "production_helper": false]
            let data = try JSONSerialization.data(withJSONObject: report, options: [.sortedKeys, .prettyPrinted])
            try data.write(to: outputDirectory.appendingPathComponent("swift-results.json"))
            print(String(decoding: data, as: UTF8.self))
        } catch {
            print("BF16 oracle failed: \(String(reflecting: error))")
            exit(1)
        }
    }
}
