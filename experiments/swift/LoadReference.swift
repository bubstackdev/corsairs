import CoreAI
import Foundation
@inline(never) public func loadCPUOptions(_ url: URL) async throws -> AIModel {
  try await AIModel(contentsOf: url, options: .cpuOnly)
}
@inline(never) public func modelNames(_ model: borrowing AIModel) -> [String] { model.functionNames }
@inline(never) public func namesCount(_ names: borrowing [String]) -> Int { names.count }
@inline(never) public func nameAt(_ names: borrowing [String], _ index: Int) -> String { names[index] }
@inline(never) public func nulTerminatedUTF8(_ string: borrowing String) -> ContiguousArray<CChar> { string.utf8CString }
@inline(never) public func utf8Count(_ bytes: borrowing ContiguousArray<CChar>) -> Int { bytes.count }
@inline(never) public func utf8At(_ bytes: borrowing ContiguousArray<CChar>, _ index: Int) -> CChar { bytes[index] }
@inline(never) public func consumeNames(_ names: __owned [String]) { }
@inline(never) public func consumeCString(_ bytes: __owned ContiguousArray<CChar>) { }
@inline(never) public func consumeString(_ string: __owned String) { }
