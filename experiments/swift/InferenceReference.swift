import CoreAI
import Foundation

@inline(never) public func loadFunction(_ model: borrowing AIModel, _ name: borrowing String) throws -> InferenceFunction? {
    try model.loadFunction(named: name)
}
@inline(never) public func runDictionary(_ function: borrowing InferenceFunction, _ inputs: borrowing [String: NDArray]) async throws -> InferenceFunction.Outputs {
    try await function.run(inputs: inputs)
}
@inline(never) public func runView(_ function: borrowing InferenceFunction, _ array: borrowing NDArray, _ name: borrowing String) async throws -> InferenceFunction.Outputs {
    var inputs = InferenceFunction.Inputs()
    inputs.insert(array.rawView(), for: name)
    return try await function.run(inputs: inputs)
}
@inline(never) public func oneDictionary(_ name: borrowing String, _ array: borrowing NDArray) -> [String: NDArray] {
    [copy name: copy array]
}
@inline(never) public func emptyDictionary() -> [String: NDArray] { [:] }
@inline(never) public func dictionaryUpdate(_ dictionary: inout [String: NDArray], _ name: borrowing String, _ array: borrowing NDArray) {
    dictionary[copy name] = copy array
}
@inline(never) public func removeOutput(_ outputs: inout InferenceFunction.Outputs, _ name: borrowing String) -> InferenceValue? {
    outputs.remove(name)
}
@inline(never) public func outputArray(_ value: consuming InferenceValue) -> NDArray? {
    value.ndArray
}
@inline(never) public func outputCount(_ outputs: borrowing InferenceFunction.Outputs) -> Int { outputs.count }
@inline(never) public func shape23() -> [Int] {
    var shape = Array(repeating: 2, count: 2)
    shape[1] = 3
    return shape
}
@inline(never) public func shapeOf(_ array: borrowing NDArray) -> [Int] { array.shape }
@inline(never) public func stridesOf(_ array: borrowing NDArray) -> [Int] { array.strides }
@inline(never) public func scalarOf(_ array: borrowing NDArray) -> NDArray.ScalarType { array.scalarType }
@inline(never) public func unwrapFunction(_ value: consuming InferenceFunction?) -> InferenceFunction {
    switch consume value {
    case .some(let function): return function
    case .none: fatalError("missing function")
    }
}
@inline(never) public func unwrapValue(_ value: consuming InferenceValue?) -> InferenceValue {
    switch consume value {
    case .some(let output): return consume output
    case .none: fatalError("missing output")
    }
}
@inline(never) public func unwrapArray(_ value: consuming NDArray?) -> NDArray {
    switch consume value {
    case .some(let array): return array
    case .none: fatalError("not NDArray")
    }
}
@inline(never) public func emptyDictionaryCapacity() -> [String: NDArray] {
    Dictionary<String, NDArray>(minimumCapacity: 0)
}
@inline(never) public func dictionaryReplace(_ dictionary: inout [String: NDArray], _ name: consuming String, _ array: consuming NDArray) -> NDArray? {
    dictionary.updateValue(consume array, forKey: consume name)
}
@inline(never) public func dictionaryLookup(_ dictionary: borrowing [String: NDArray], _ name: borrowing String) -> NDArray? {
    dictionary[copy name]
}
@inline(never) public func consumeDictionary(_ dictionary: __owned [String: NDArray]) { }
@inline(never) public func dictionaryType<K: Hashable, V>(_: K.Type, _: V.Type) -> Any.Type {
    Dictionary<K,V>.self
}
