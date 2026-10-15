// Compiler-only reference: never linked into Corsairs.
import CoreAI

@inline(never)
public func borrowedFunctionLoad(_ model: borrowing AIModel, _ name: borrowing String) throws -> InferenceFunction? {
    try model.loadFunction(named: name)
}

@inline(never)
public func detachedFunctionLoad(_ model: AIModel, _ name: String) -> Task<InferenceFunction?, Error> {
    Task.detached {
        try model.loadFunction(named: name)
    }
}

@inline(never)
public func verifySendableConformances() {
    func requireSendable<T: Sendable>(_ type: T.Type) {}
    requireSendable(AIModel.self)
    requireSendable(InferenceFunction.self)
}
