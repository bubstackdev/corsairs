// Compiler-only reference: aggregate, self, errors, and asynchronous contexts.
public struct Triple { public var a, b, c: UInt64 }
public func aggregate3(_ value: Triple) -> Triple { value }
public class Object { public func compute(_ value: UInt64) -> UInt64 { value } }
public enum ExampleError: Error { case zero }
public func throwing(_ value: UInt64) throws -> UInt64 {
    if value == 0 { throw ExampleError.zero }
    return value
}
public func asyncExample(_ value: UInt64) async -> UInt64 { value }
