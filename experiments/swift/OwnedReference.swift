import CoreAI
@inline(never) public func gpuOptions() -> SpecializationOptions { SpecializationOptions(preferredComputeUnitKind: .gpu) }
@inline(never) public func functionDescriptor(_ f: borrowing InferenceFunction) -> InferenceFunctionDescriptor { f.descriptor }
@inline(never) public func descriptorName(_ d: borrowing InferenceFunctionDescriptor) -> String { d.name }
@inline(never) public func inputNames(_ d: borrowing InferenceFunctionDescriptor) -> [String] { d.inputNames }
@inline(never) public func outputNames(_ d: borrowing InferenceFunctionDescriptor) -> [String] { d.outputNames }
@inline(never) public func stateNames(_ d: borrowing InferenceFunctionDescriptor) -> [String] { d.stateNames }
@inline(never) public func inputDescriptor(_ d: borrowing InferenceFunctionDescriptor, _ n: borrowing String) -> InferenceValue.Descriptor? { d.inputDescriptor(of:n) }
@inline(never) public func outputDescriptor(_ d: borrowing InferenceFunctionDescriptor, _ n: borrowing String) -> InferenceValue.Descriptor? { d.outputDescriptor(of:n) }
@inline(never) public func stateDescriptor(_ d: borrowing InferenceFunctionDescriptor, _ n: borrowing String) -> InferenceValue.Descriptor? { d.stateDescriptor(of:n) }
@inline(never) public func ndarrayDescriptor(_ d: consuming InferenceValue.Descriptor) -> NDArrayDescriptor? {
 switch consume d {case .ndArray(let d):return d;case .image:return nil; @unknown default:return nil}
}
@inline(never) public func shape(_ d: borrowing NDArrayDescriptor) -> [Int] {d.shape}
@inline(never) public func scalar(_ d: borrowing NDArrayDescriptor) -> NDArray.ScalarType {d.scalarType}
@inline(never) public func insertMutable(_ array: inout NDArray, _ n: borrowing String) {
 var views = InferenceFunction.MutableViews()
 views.insert(array.mutableRawView(),for:n)
}
