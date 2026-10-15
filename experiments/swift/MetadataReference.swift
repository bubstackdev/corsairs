// Standalone validation executable; never linked into the Rust experiment.
import CoreAI
import Foundation

func layout<T>(_ name: String, _: T.Type) -> [String: Any] {
    ["name": name, "size": MemoryLayout<T>.size,
     "stride": MemoryLayout<T>.stride, "alignment": MemoryLayout<T>.alignment]
}

let layouts = [
    layout("NDArray", NDArray.self),
    layout("ScalarType", NDArray.ScalarType.self),
    layout("AIModel", AIModel.self),
    layout("InferenceFunction", InferenceFunction.self),
]
let data = try JSONSerialization.data(withJSONObject: layouts, options: [.sortedKeys])
print(String(decoding: data, as: UTF8.self))

