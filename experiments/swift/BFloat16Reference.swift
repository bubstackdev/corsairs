import CoreAI

// Independent compiler evidence: BF16 is a distinct native enum case.
@inline(never) public func bfloat16Scalar() -> NDArray.ScalarType { .bfloat16 }
@inline(never) public func float16ScalarForComparison() -> NDArray.ScalarType { .float16 }
@inline(never) public func bfloat16Array(_ shape: consuming [Int]) -> NDArray {
    NDArray(shape: shape, scalarType: .bfloat16)
}
@inline(never) public func isBFloat16(_ array: borrowing NDArray) -> Bool {
    array.scalarType == .bfloat16
}
