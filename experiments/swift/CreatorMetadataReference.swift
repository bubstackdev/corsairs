import CoreAI
import Foundation

// Calibrates AIModelAsset.Metadata.creatorDefinedMetadata. Each wrapper calls
// exactly one accessor so `-emit-ir` shows its swiftcc signature:
//   -O     fixes the getter, CreatorDefinedValue case tags (`WC` constants),
//          getEnumTag / destructiveProjectEnumData and each payload's load;
//   -Onone fixes the generic Dictionary and Array entry points, whose
//          optimized bodies inline (see docs/abi-contracts.md).
// The run mode prints, for each asset argument, the tagged values Rust must
// reproduce: numbers as IEEE-754 bit patterns, integers as exact JSON integers.

public typealias CreatorValue = AIModelAsset.Metadata.CreatorDefinedValue

@inline(never) public func openAsset(_ url: URL) throws -> AIModelAsset { try AIModelAsset(contentsOf: url) }
@inline(never) public func assetMetadata(_ asset: borrowing AIModelAsset) -> AIModelAsset.Metadata { asset.metadata }
@inline(never) public func creatorDefined(_ metadata: borrowing AIModelAsset.Metadata) -> [String: CreatorValue] {
    metadata.creatorDefinedMetadata
}

// Case tags. A resilient enum's client loads each case's `WC` constant and
// compares it with the value witness getEnumTag result.
@inline(never) public func caseIndex(_ value: CreatorValue) -> Int {
    switch value {
    case .string: 0
    case .integer: 1
    case .number: 2
    case .bool: 3
    case .array: 4
    case .dictionary: 5
    @unknown default: -1
    }
}

// Payload projection: destructiveProjectEnumData, then the payload's take.
@inline(never) public func stringPayload(_ value: consuming CreatorValue) -> String? {
    if case .string(let payload) = value { payload } else { nil }
}
@inline(never) public func integerPayload(_ value: consuming CreatorValue) -> Int? {
    if case .integer(let payload) = value { payload } else { nil }
}
@inline(never) public func numberPayload(_ value: consuming CreatorValue) -> Double? {
    if case .number(let payload) = value { payload } else { nil }
}
@inline(never) public func boolPayload(_ value: consuming CreatorValue) -> Bool? {
    if case .bool(let payload) = value { payload } else { nil }
}
@inline(never) public func arrayPayload(_ value: consuming CreatorValue) -> [CreatorValue]? {
    if case .array(let payload) = value { payload } else { nil }
}
@inline(never) public func dictionaryPayload(_ value: consuming CreatorValue) -> [String: CreatorValue]? {
    if case .dictionary(let payload) = value { payload } else { nil }
}

// Generic Dictionary/Array entry points (read from the -Onone IR).
@inline(never) public func entryCount<K, V>(_ dictionary: [K: V]) -> Int { dictionary.count }
@inline(never) public func entryKeys<K, V>(_ dictionary: [K: V]) -> Dictionary<K, V>.Keys { dictionary.keys }
@inline(never) public func keyIterator<K, V>(_ keys: consuming Dictionary<K, V>.Keys) -> Dictionary<K, V>.Keys.Iterator {
    keys.makeIterator()
}
@inline(never) public func nextKey<K, V>(_ iterator: inout Dictionary<K, V>.Keys.Iterator) -> K? { iterator.next() }
@inline(never) public func lookup<K, V>(_ dictionary: [K: V], _ key: K) -> V? { dictionary[key] }
@inline(never) public func elementCount<T>(_ array: [T]) -> Int { array.count }
@inline(never) public func element<T>(_ array: [T], _ index: Int) -> T { array[index] }

// Concrete call sites: show the String/CreatorDefinedValue metadata and the
// String: Hashable witness table passed to the generic entry points.
@inline(never) public func creatorKeys(_ dictionary: [String: CreatorValue]) -> [String] {
    var iterator = keyIterator(entryKeys(dictionary))
    var keys: [String] = []
    keys.reserveCapacity(entryCount(dictionary))
    while let key = nextKey(&iterator) { keys.append(key) }
    return keys
}
@inline(never) public func creatorLookup(_ dictionary: [String: CreatorValue], _ key: String) -> CreatorValue? {
    lookup(dictionary, key)
}
@inline(never) public func creatorElement(_ array: [CreatorValue], _ index: Int) -> CreatorValue {
    precondition(index < elementCount(array))
    return element(array, index)
}

func tagged(_ value: CreatorValue) -> Any {
    // Ordinary pattern matching and iteration, independent of the wrappers
    // above, so the report is an oracle rather than a replay of Rust's path.
    switch value {
    case .string(let text): ["string": text]
    case .integer(let integer): ["integer": integer]
    case .number(let number): ["number_bits": String(format: "%016llx", number.bitPattern)]
    case .bool(let flag): ["bool": flag]
    case .array(let values): ["array": values.map(tagged)]
    case .dictionary(let entries): ["dictionary": tagged(entries)]
    @unknown default: ["unknown": String(describing: value)]
    }
}
func tagged(_ dictionary: [String: CreatorValue]) -> [String: Any] {
    var result: [String: Any] = [:]
    for (key, value) in dictionary { result[key] = tagged(value) }
    return result
}

func report(_ path: String) -> [String: Any] {
    var row: [String: Any] = ["path": path]
    do {
        let metadata = assetMetadata(try openAsset(URL(fileURLWithPath: path)))
        row["creator_defined"] = tagged(metadata.creatorDefinedMetadata)
        row["author"] = metadata.author
    } catch {
        row["error_type"] = _typeName(type(of: error), qualified: true)
        row["error"] = String(describing: error)
    }
    return row
}

@main struct CreatorMetadataOracle {
    static func main() throws {
        let rows = CommandLine.arguments.dropFirst().map(report)
        let bytes = try JSONSerialization.data(withJSONObject: ["assets": rows], options: [.sortedKeys, .prettyPrinted])
        print(String(decoding: bytes, as: UTF8.self))
    }
}
