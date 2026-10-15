// Deterministic test-only Swift error lifetime oracle; never shipped in Corsairs.
import CoreAI
import Synchronization

private let payloadCounts = Mutex((created: UInt32(0), destroyed: UInt32(0)))
private final class Payload: @unchecked Sendable {
    init() { payloadCounts.withLock { $0.created += 1 } }
    deinit { payloadCounts.withLock { $0.destroyed += 1 } }
}
public struct DeliberateFailure: Error {
    private let payload: Payload
    fileprivate init() { payload = Payload() }
}

extension AIModel {
    // Instance-method lowering deliberately matches loadFunction(named:).
    @_silgen_name("corsairs_function_throw_oracle")
    public func functionThrowOracle(named name: borrowing String) throws -> InferenceFunction? {
        if name == "__corsairs_swift_throw__" { throw DeliberateFailure() }
        return try loadFunction(named: name)
    }
}

@_cdecl("corsairs_function_throw_counts")
public func functionThrowCounts() -> UInt64 {
    payloadCounts.withLock { (UInt64($0.created) << 32) | UInt64($0.destroyed) }
}
