// Standalone bitwise oracle. This executable never runs in the Rust process.
import CoreAI
import Foundation

@main struct BufferRunReference {
    static func main() throws {
        let patterns: [[UInt32]] = [
            [0x3f800000, 0xc0200000, 0, 0x80000000],
            [0x7f800000, 0xff800000, 0x7fc12345, 1],
            [0x7f7fffff, 0x00800000, 0x3eaaaaab, 0xffc12345],
        ]
        var tensor = NDArray(shape: [2, 2], scalarType: .float32)
        var results: [[UInt32]] = []
        for pattern in patterns {
            pattern.withUnsafeBufferPointer { writeValues(&tensor, $0.baseAddress!) }
            var actual = [UInt32](repeating: 0, count: 4)
            actual.withUnsafeMutableBufferPointer { readValues(tensor, $0.baseAddress!) }
            precondition(actual == pattern)
            results.append(actual)
        }
        let output: [String: Any] = ["shape": tensor.shape, "is_float32": tensor.scalarType == .float32, "content_bits": results]
        let data = try JSONSerialization.data(withJSONObject: output, options: [.sortedKeys])
        print(String(decoding: data, as: UTF8.self))
    }
}
