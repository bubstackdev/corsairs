import CoreAI
import Foundation

// Writes nested creator-defined metadata into a scratch copy of an asset so the
// read-only Rust binding can be checked case for case. Values are what Core AI
// is asked to store; CreatorMetadataReference.swift reports what it reads back
// (whole numbers return as integers, and 0, 1 and -0.0 as booleans). NaN and
// ±infinity are omitted: updateMetadata aborts the process on them with an
// uncaught NSInvalidArgumentException from JSONSerialization.
typealias Value = AIModelAsset.Metadata.CreatorDefinedValue

func nested(_ depth: Int) -> Value {
    depth == 0 ? ["leaf": "bottom", "depth": .integer(40)] : [nested(depth - 1)]
}

@main struct CreatorMetadataWriter {
    static func main() throws {
        let arguments = CommandLine.arguments
        guard arguments.count == 3 else { fatalError("usage: SOURCE_ASSET DESTINATION_ASSET") }
        let destination = URL(fileURLWithPath: arguments[2])
        try? FileManager.default.removeItem(at: destination)
        try FileManager.default.copyItem(at: URL(fileURLWithPath: arguments[1]), to: destination)
        var asset = try AIModelAsset(contentsOf: destination)
        try asset.updateMetadata { metadata in
            metadata.author = "Creator metadata fixture"
            metadata.creatorDefinedMetadata = [
                "string": "plain",
                "string_empty": "",
                "string_unicode": "Zoë 🏴‍☠️ \"quoted\"\nline\t× 日本語 \u{0}nul",
                "integer_max": .integer(Int.max),
                "integer_min": .integer(Int.min),
                "integer_negative": -42,
                "integer_two": 2,
                "integer_zero": .integer(0),
                "integer_one": .integer(1),
                "number": 0.1,
                "number_negative": -2.5,
                "number_large": 1e300,
                "number_max": .number(.greatestFiniteMagnitude),
                "number_min_normal": .number(.leastNormalMagnitude),
                "number_subnormal": .number(.leastNonzeroMagnitude),
                "number_whole": 3.0,
                "number_negative_zero": .number(-0.0),
                "bool_true": true,
                "bool_false": false,
                "array_empty": [],
                "dictionary_empty": [:],
                "array_mixed": ["a", 7, 1.5, true, [], [:], [[["deep"]]], ["k": "v"]],
                "dictionary": [
                    "nested": ["inner": ["list": [1, 2, [:], []]]],
                    "": "empty key",
                    "ключ": "значение",
                    "🔑": "emoji key",
                    "\u{e9}": "precomposed e-acute key",
                ],
                "dictionary_decomposed": ["e\u{301}": "decomposed e-acute key"],
                "": "empty top-level key",
                "日本語キー": ["配列", 7, ["キー": false]],
                "nested_40": nested(40),
            ]
        }
        print(destination.path)
    }
}
