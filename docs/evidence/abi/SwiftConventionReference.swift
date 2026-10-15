public struct Big { public var a, b, c, d, e: UInt64 }
public class Object { public func compute(_ x: UInt64) -> UInt64 { x } }
public enum Err: Error { case zero }
public func throwing(_ x: UInt64) throws -> UInt64 { if x == 0 { throw Err.zero }; return x }
public func asyncExample(_ x: UInt64) async -> UInt64 { x }
public func aggregate(_ x: Big) -> Big { x }
