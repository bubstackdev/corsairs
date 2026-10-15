import CoreAI
@inline(never) public func mutableSpan(_ tensor: inout NDArray) -> (UnsafeMutableRawPointer, Int) {
    var bytes = tensor.mutableRawView().mutableBytes
    return bytes.withUnsafeMutableBytes { ($0.baseAddress!, $0.count) }
}
@inline(never) public func mutableClosure(_ tensor: inout NDArray) -> UnsafeMutableRawPointer {
    tensor.mutableRawView().withUnsafeMutableBytes { pointer, _, _ in pointer }
}
@inline(never) public func rawSpan(_ tensor: borrowing NDArray) -> (UnsafeRawPointer, Int) {
    tensor.rawView().bytes.withUnsafeBytes { ($0.baseAddress!, $0.count) }
}
@inline(never) public func rawClosure(_ tensor: borrowing NDArray) -> UnsafeRawPointer {
    tensor.rawView().withUnsafeBytes { pointer, _, _ in pointer }
}
