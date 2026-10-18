import CoreAI
import Foundation

// Writes known metadata into a scratch copy of an asset so the read-only Rust
// binding can be checked against non-empty, non-ASCII strings and a set date.
@main struct AssetMetadataWriter {
    static func main() throws {
        let arguments = CommandLine.arguments
        guard arguments.count == 3 else { fatalError("usage: SOURCE_ASSET DESTINATION_ASSET") }
        let destination = URL(fileURLWithPath: arguments[2])
        try? FileManager.default.removeItem(at: destination)
        try FileManager.default.copyItem(at: URL(fileURLWithPath: arguments[1]), to: destination)
        var asset = try AIModelAsset(contentsOf: destination)
        try asset.updateMetadata { metadata in
            metadata.author = "Zoë Corsair 🏴‍☠️"
            metadata.license = "MIT OR Apache-2.0"
            metadata.description = "x + x \"quoted\"\nsecond line\t× ünïcødé"
            metadata.creationDate = Date(timeIntervalSince1970: 1_234_567_890.25)
        }
        print(destination.path)
    }
}
