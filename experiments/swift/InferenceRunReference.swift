import CoreAI
import Foundation

struct OracleError: Error { let message: String }

@inline(never)
func execute(path: String) async throws -> [String: Any] {
    let model = try await AIModel(contentsOf: URL(fileURLWithPath: path), options: .cpuOnly)
    guard let function = try model.loadFunction(named: "main") else {
        throw OracleError(message: "missing main")
    }
    let values: [Float] = [1, -2, 0, 0.5, 100, -0.25]
    let expected: [Float] = [2, -4, 0, 1, 200, -0.5]
    var array = NDArray(shape: [2, 3], scalarType: .float32)
    array.mutableRawView().withUnsafeMutableBytes { destination, _, _ in
        values.withUnsafeBytes { source in
            destination.copyMemory(from: source.baseAddress!, byteCount: source.count)
        }
    }
    var inputs = InferenceFunction.Inputs()
    inputs.insert(array.rawView(), for: "x")
    var outputs = try await function.run(inputs: inputs)
    let outputCount = outputs.count
    guard let value = outputs.remove("y") else { throw OracleError(message: "missing y") }
    guard let result = value.ndArray else { throw OracleError(message: "y is not NDArray") }
    let shape = result.shape
    let strides = result.strides
    let float32 = result.scalarType == .float32
    guard shape == [2,3] && strides == [3,1] && float32 else {
        throw OracleError(message: "unexpected output metadata")
    }
    let bytes = result.rawView().withUnsafeBytes { start, _, _ in Data(bytes: start, count: 24) }
    let expectedBytes = expected.withUnsafeBytes { Data($0) }
    let actualValues: [Float] = result.rawView().withUnsafeBytes { start, _, _ in
        Array(UnsafeBufferPointer(start: start.assumingMemoryBound(to: Float.self), count: 6))
    }
    return ["function": "main", "output_count": outputCount,
            "output_shape": shape, "output_strides": strides, "is_float32": float32,
            "values": actualValues, "exact_bytes_match": bytes == expectedBytes,
            "remaining_outputs": outputs.count]
}

@main struct InferenceOracle {
    static func main() async throws {
        guard CommandLine.arguments.count == 2 else {
            print("usage: inference-oracle ASSET_PATH")
            exit(2)
        }
        let output: [String: Any]
        let status: Int32
        do {
            let result = try await execute(path: CommandLine.arguments[1])
            output = result
            status = result["exact_bytes_match"] as? Bool == true ? 0 : 1
        } catch {
            output = ["error_type": _typeName(type(of: error), qualified: true),
                      "description": String(describing: error)]
            status = 1
        }
        let bytes = try JSONSerialization.data(withJSONObject: output, options: [.sortedKeys])
        print(String(decoding: bytes, as: UTF8.self))
        exit(status)
    }
}
