import CoreAI
import Foundation

@main struct ErrorRunReference {
    static func main() throws {
        do {
            let model = try AIModel(resolvingBookmark: Data())
            let output: [String: Any] = ["caught": false, "was_nil": model == nil]
            let data = try JSONSerialization.data(withJSONObject: output, options: [.sortedKeys])
            print(String(decoding: data, as: UTF8.self))
        } catch {
            let output: [String: Any] = ["caught": true, "error_type": String(reflecting: type(of: error))]
            let data = try JSONSerialization.data(withJSONObject: output, options: [.sortedKeys])
            print(String(decoding: data, as: UTF8.self))
        }
    }
}
