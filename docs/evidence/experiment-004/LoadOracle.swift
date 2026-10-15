import CoreAI
import Foundation

@inline(never)
func loadAndReadNames(path: String, cpuOnly: Bool) async throws -> [String] {
    let model = try await AIModel(
        contentsOf: URL(fileURLWithPath: path),
        options: cpuOnly ? .cpuOnly : .default
    )
    return model.functionNames
}

@main struct LoadOracle {
    static func main() async throws {
        let arguments = CommandLine.arguments
        guard arguments.count == 2 || arguments.count == 3 else {
            print("usage: load-oracle ASSET_PATH [cpuOnly|default]")
            exit(2)
        }
        let mode = arguments.count == 3 ? arguments[2] : "cpuOnly"
        guard mode == "cpuOnly" || mode == "default" else { exit(2) }
        let output: [String: Any]
        let status: Int32
        do {
            let names = try await loadAndReadNames(path: arguments[1], cpuOnly: mode == "cpuOnly")
            output = ["loaded": true, "mode": mode, "function_names": names]
            status = 0
        } catch {
            output = ["loaded": false, "mode": mode,
                      "error_type": _typeName(type(of: error), qualified: true),
                      "description": String(describing: error)]
            status = 1
        }
        let data = try JSONSerialization.data(withJSONObject: output, options: [.sortedKeys])
        print(String(decoding: data, as: UTF8.self))
        exit(status)
    }
}
