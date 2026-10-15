// Compiler oracle for the exact calls investigated in the Rust experiment.
import CoreAI

@inline(never)
public func makeTensor(_ dimension: Int, _ rank: Int) -> NDArray {
    NDArray(shape: Array(repeating: dimension, count: rank), scalarType: .float32)
}

@inline(never)
public func shape(_ tensor: NDArray) -> [Int] {
    tensor.shape
}

@inline(never)
public func scalarType(_ tensor: NDArray) -> NDArray.ScalarType {
    tensor.scalarType
}

@inline(never)
public func destroyTensor(_ tensor: consuming NDArray) {
    // A consumed native value leaves scope here, exercising its value witness.
    _ = tensor
}

@inline(never)
public func arrayCount<T>(_ values: [T]) -> Int {
    values.count
}

@inline(never)
public func arrayElement<T>(_ values: [T], _ index: Int) -> T {
    values[index]
}
