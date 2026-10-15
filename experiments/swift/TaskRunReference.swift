import Foundation

@main struct TaskRunReference {
    static func main() async throws {
        let inside = await Task.detached {
            withUnsafeCurrentTask { $0 != nil }
        }.value
        let result: [String: Any] = ["completed": true, "body_has_current_task": inside]
        let data = try JSONSerialization.data(withJSONObject: result, options: [.sortedKeys])
        print(String(decoding: data, as: UTF8.self))
    }
}
