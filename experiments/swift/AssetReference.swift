import CoreAI
import Foundation

// Calibrates the read-only asset metadata/summary accessors. Each wrapper calls
// exactly one SDK accessor so `-emit-ir` shows its swiftcc signature; the run
// mode prints the values Rust must reproduce for each asset argument.

@inline(never) public func openAsset(_ url: URL) throws -> AIModelAsset { try AIModelAsset(contentsOf: url) }
@inline(never) public func isValidAsset(_ url: URL) -> Bool { AIModelAsset.isValid(at: url) }
@inline(never) public func assetMetadata(_ asset: borrowing AIModelAsset) -> AIModelAsset.Metadata { asset.metadata }
@inline(never) public func author(_ metadata: borrowing AIModelAsset.Metadata) -> String { metadata.author }
@inline(never) public func license(_ metadata: borrowing AIModelAsset.Metadata) -> String { metadata.license }
@inline(never) public func summaryText(_ metadata: borrowing AIModelAsset.Metadata) -> String { metadata.description }
@inline(never) public func creationDate(_ metadata: borrowing AIModelAsset.Metadata) -> Date? { metadata.creationDate }
@inline(never) public func unixSeconds(_ date: Date) -> Double { date.timeIntervalSince1970 }
@inline(never) public func summary(_ asset: borrowing AIModelAsset, _ statistics: Bool) throws -> AIModelAsset.Summary? {
    try asset.summary(includingStatistics: statistics)
}
@inline(never) public func functions(_ summary: borrowing AIModelAsset.Summary) -> [AIModelAsset.FunctionDescriptor] { summary.functions }
@inline(never) public func storageTypes(_ summary: borrowing AIModelAsset.Summary) -> [AIModelAsset.Summary.StorageType] { summary.storageTypes }
@inline(never) public func computeTypes(_ summary: borrowing AIModelAsset.Summary) -> [String] { summary.computeTypes }
@inline(never) public func operations(_ summary: borrowing AIModelAsset.Summary) -> [AIModelAsset.Summary.OperationCount] { summary.operationDistribution }
@inline(never) public func functionName(_ function: borrowing AIModelAsset.FunctionDescriptor) -> String { function.name }
@inline(never) public func functionInputs(_ function: borrowing AIModelAsset.FunctionDescriptor) -> [AIModelAsset.ValueDescriptor] { function.inputs }
@inline(never) public func valueName(_ value: borrowing AIModelAsset.ValueDescriptor) -> String { value.name }
@inline(never) public func valueType(_ value: borrowing AIModelAsset.ValueDescriptor) -> String { value.typeName }
@inline(never) public func storageName(_ storage: borrowing AIModelAsset.Summary.StorageType) -> String { storage.typeName }
@inline(never) public func storageCount(_ storage: borrowing AIModelAsset.Summary.StorageType) -> Int { storage.count }
@inline(never) public func operationName(_ operation: borrowing AIModelAsset.Summary.OperationCount) -> String { operation.operationName }
@inline(never) public func operationCount(_ operation: borrowing AIModelAsset.Summary.OperationCount) -> Int { operation.count }
@inline(never) public func architecture() -> String { AIModel.deviceArchitectureName }

func values(_ list: [AIModelAsset.ValueDescriptor]) -> [[String: String]] {
    list.map { ["name": valueName($0), "type_name": valueType($0)] }
}

func report(_ path: String) -> [String: Any] {
    let url = URL(fileURLWithPath: path)
    var row: [String: Any] = ["path": path, "is_valid": isValidAsset(url)]
    do {
        let asset = try openAsset(url)
        let metadata = assetMetadata(asset)
        row["metadata"] = ["author": author(metadata), "license": license(metadata),
                           "description": summaryText(metadata),
                           "creation_unix_seconds": creationDate(metadata).map(unixSeconds) ?? NSNull()]
        for statistics in [false, true] {
            guard let summary = try summary(asset, statistics) else {
                row["summary_\(statistics)"] = NSNull()
                continue
            }
            row["summary_\(statistics)"] = [
                "functions": functions(summary).map {
                    ["name": functionName($0), "inputs": values(functionInputs($0)),
                     "states": values($0.states), "outputs": values($0.outputs)]
                },
                "storage_types": storageTypes(summary).map { ["type_name": storageName($0), "count": storageCount($0)] },
                "compute_types": computeTypes(summary),
                "operations": operations(summary).map { ["name": operationName($0), "count": operationCount($0)] },
            ]
        }
    } catch {
        row["error_type"] = _typeName(type(of: error), qualified: true)
        row["error"] = String(describing: error)
    }
    return row
}

@main struct AssetOracle {
    static func main() throws {
        let rows = CommandLine.arguments.dropFirst().map(report)
        let output: [String: Any] = ["device_architecture": architecture(), "assets": rows]
        let bytes = try JSONSerialization.data(withJSONObject: output, options: [.sortedKeys, .prettyPrinted])
        print(String(decoding: bytes, as: UTF8.self))
    }
}
