import CoreAI
import Foundation

@inline(never)
public func makeFileURL(_ bytes: UnsafePointer<CChar>) -> URL {
    URL(fileURLWithPath: String(cString: bytes))
}

@inline(never)
public func loadAsset(_ url: consuming URL) throws -> AIModelAsset {
    try AIModelAsset(contentsOf: url)
}

@inline(never)
public func inspectAsset(_ asset: AIModelAsset) throws -> AIModelAsset.Summary? {
    try asset.summary(includingStatistics: true)
}

@inline(never)
public func resolveEmptyBookmark() throws -> AIModel? {
    try AIModel(resolvingBookmark: Data())
}

@inline(never)
public func errorType(_ error: any Error) -> String {
    _typeName(type(of: error), qualified: true)
}
