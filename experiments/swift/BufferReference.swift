// Compiler reference only. Rust calls the existing native symbols directly.
import CoreAI

@inline(never)
public func writeValues(_ tensor: inout NDArray, _ values: UnsafePointer<UInt32>) {
    var bytes = tensor.mutableRawView().mutableBytes
    bytes.withUnsafeMutableBytes { buffer in
        buffer.baseAddress!.copyMemory(from: values, byteCount: 16)
    }
}

@inline(never)
public func readValues(_ tensor: NDArray, _ values: UnsafeMutablePointer<UInt32>) {
    let bytes = tensor.rawView().bytes
    bytes.withUnsafeBytes { buffer in
        values.update(from: buffer.baseAddress!.assumingMemoryBound(to: UInt32.self), count: 4)
    }
}
