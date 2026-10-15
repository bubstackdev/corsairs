import CoreAI
import CryptoKit
import Darwin
import Foundation

enum CapacityError: Error { case failed(String) }
func require(_ condition: Bool, _ reason: String) throws {
    if !condition { throw CapacityError.failed(reason) }
}
let blockBytes = 1 << 20
func block(_ index: Int, _ width: Int, _ factor: Float) -> Data {
    let seed = Float(1 + index % 251)
    let values: [Float] = [seed, -seed, 1, -1, 2, -2, 64, -64]
    var period = Data()
    for value in values {
        let bits = (value * factor).bitPattern
        if width == 2 {
            var narrow = UInt16(bits >> 16).littleEndian
            withUnsafeBytes(of: &narrow) { period.append(contentsOf: $0) }
        } else {
            var full = bits.littleEndian
            withUnsafeBytes(of: &full) { period.append(contentsOf: $0) }
        }
    }
    var data = Data(count: blockBytes)
    data.withUnsafeMutableBytes { destination in
        period.withUnsafeBytes { source in
            for offset in stride(from: 0, to: blockBytes, by: period.count) {
                destination.baseAddress!.advanced(by: offset).copyMemory(from: source.baseAddress!, byteCount: period.count)
            }
        }
    }
    return data
}
func fill(_ array: inout NDArray, _ bytes: Int, _ width: Int) {
    array.mutableRawView().withUnsafeMutableBytes { pointer, _, _ in
        for offset in stride(from: 0, to: bytes, by: blockBytes) {
            let pattern = block(offset / blockBytes, width, 1)
            pattern.withUnsafeBytes { source in
                pointer.advanced(by: offset).copyMemory(from: source.baseAddress!, byteCount: min(blockBytes, bytes - offset))
            }
        }
    }
}
func verify(_ array: borrowing NDArray, _ shape: [Int], _ bytes: Int, _ width: Int, _ factor: Float) throws -> String {
    try require(array.shape == shape, "shape")
    try require(array.scalarType == (width == 2 ? .bfloat16 : .float32), "dtype")
    var strides = [Int](repeating: 0, count: shape.count)
    var stride = 1
    for axis in shape.indices.reversed() { strides[axis] = stride; stride *= shape[axis] }
    try require(array.strides == strides, "row-major native output")
    return try array.rawView().withUnsafeBytes { pointer, _, _ in
        var digest = SHA256()
        for offset in Swift.stride(from: 0, to: bytes, by: blockBytes) {
            let pattern = block(offset / blockBytes, width, factor)
            let count = min(blockBytes, bytes - offset)
            let equal = pattern.withUnsafeBytes { source in memcmp(pointer.advanced(by: offset), source.baseAddress!, count) == 0 }
            try require(equal, "byte mismatch at block \(offset / blockBytes)")
            digest.update(bufferPointer: UnsafeRawBufferPointer(start: pointer.advanced(by: offset), count: count))
        }
        return digest.finalize().map { String(format: "%02x", $0) }.joined()
    }
}
func run(_ function: InferenceFunction, _ input: NDArray) async throws -> NDArray {
    var outputs = try await function.run(inputs: ["x": input])
    guard let value = outputs.remove("y"), let array = value.ndArray else { throw CapacityError.failed("missing output") }
    return array
}
@main struct LargeTensorReference {
    static func main() async throws {
        let args = CommandLine.arguments
        guard args.count == 7 else { fatalError("MODEL DTYPE SHAPE COMPUTE CASE REPORT") }
        let shape = args[3].split(separator: ",").map { Int($0)! }
        let width = args[2] == "bfloat16" ? 2 : 4
        let bytes = shape.reduce(width, *)
        let options: SpecializationOptions = args[4] == "cpu" ? .cpuOnly : SpecializationOptions(preferredComputeUnitKind: .gpu)
        let model = try await AIModel(contentsOf: URL(fileURLWithPath: args[1]), options: options)
        guard let function = try model.loadFunction(named: "main") else { throw CapacityError.failed("function") }
        print("{\"event\":\"allocated\",\"bytes\":\(bytes)}")
        var input = NDArray(shape: shape, scalarType: width == 2 ? .bfloat16 : .float32)
        fill(&input, bytes, width)
        let inputHash = try verify(input, shape, bytes, width, 1)
        let first = try await run(function, input)
        let doubleHash = try verify(first, shape, bytes, width, 2)
        print("{\"event\":\"double_complete\",\"bytes\":\(bytes)}")
        let second = try await run(function, first)
        let chainHash = try verify(second, shape, bytes, width, 4)
        let report: [String: Any] = ["passed": true, "case": args[5], "compute": args[4], "dtype": args[2],
            "shape": shape, "bytes": bytes, "input_sha256": inputHash, "double_sha256": doubleHash,
            "chain_sha256": chainHash, "production_helper": false]
        let data = try JSONSerialization.data(withJSONObject: report, options: [.sortedKeys, .prettyPrinted])
        try data.write(to: URL(fileURLWithPath: args[6]))
        print(String(decoding: data, as: UTF8.self))
    }
}
