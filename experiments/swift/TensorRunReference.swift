// Standalone behavior oracle; not linked into the Rust application.
import CoreAI
import Foundation

let tensor = NDArray(shape: Array(repeating: 2, count: 2), scalarType: .float32)
let result: [String: Any] = ["shape": tensor.shape, "is_float32": tensor.scalarType == .float32]
let data = try JSONSerialization.data(withJSONObject: result, options: [.sortedKeys])
print(String(decoding: data, as: UTF8.self))
