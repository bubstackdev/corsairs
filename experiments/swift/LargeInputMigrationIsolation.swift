// Test-only x+x NDArray input/migration isolation; no production runtime changes.
// Each invocation selects one mode and must run in a separate, coordinated process.
import CoreAI
import CryptoKit
import Darwin
import Foundation
import Metal

enum IsolationError: Error { case failed(String) }
func require(_ condition: Bool, _ message: String) throws {
    if !condition { throw IsolationError.failed(message) }
}
func event(_ fields: [String: Any]) {
    let data = try! JSONSerialization.data(withJSONObject: fields, options: [.sortedKeys])
    print(String(decoding: data, as: UTF8.self))
    fflush(stdout)
}
let blockBytes = 1 << 20
func pattern(_ index: Int, _ factor: Float) -> Data {
    let seed = Float(1 + index % 251)
    var words: [UInt32] = [seed, -seed, 1, -1, 2, -2, 64, -64].map {
        ($0 * factor).bitPattern.littleEndian
    }
    return words.withUnsafeMutableBytes { period in
        var data = Data(count: blockBytes)
        data.withUnsafeMutableBytes { destination in
            for offset in stride(from: 0, to: blockBytes, by: period.count) {
                destination.baseAddress!.advanced(by: offset).copyMemory(
                    from: period.baseAddress!, byteCount: period.count)
            }
        }
        return data
    }
}
func fill(_ buffer: any MTLBuffer, _ count: Int) {
    for offset in stride(from: 0, to: count, by: blockBytes) {
        pattern(offset / blockBytes, 1).withUnsafeBytes { source in
            buffer.contents().advanced(by: offset).copyMemory(
                from: source.baseAddress!, byteCount: min(blockBytes, count - offset))
        }
    }
}
func verifySnapshot(_ snapshot: Data, _ count: Int, _ factor: Float) throws -> String {
    try require(snapshot.count == count, "snapshot byte count")
    return try snapshot.withUnsafeBytes { captured in
        var digest = SHA256()
        for offset in stride(from: 0, to: count, by: blockBytes) {
            let length = min(blockBytes, count - offset)
            let equal = pattern(offset / blockBytes, factor).withUnsafeBytes { expected in
                memcmp(captured.baseAddress!.advanced(by: offset), expected.baseAddress!, length) == 0
            }
            try require(equal, "byte mismatch at block \(offset / blockBytes)")
            digest.update(bufferPointer: UnsafeRawBufferPointer(
                start: captured.baseAddress!.advanced(by: offset), count: length))
        }
        return digest.finalize().map { String(format: "%02x", $0) }.joined()
    }
}
func checkMetadata(_ array: borrowing NDArray, _ shape: [Int]) throws {
    let actualShape = array.shape
    let actualType = array.scalarType
    try require(actualShape == shape && actualType == .float32, "ready NDArray shape/dtype")
    var expected = [Int](repeating: 0, count: shape.count)
    var current = 1
    for i in shape.indices.reversed() { expected[i] = current; current *= shape[i] }
    try require(array.strides == expected, "ready NDArray row-major strides")
}
func arraySnapshot(_ array: borrowing NDArray, _ count: Int) -> Data {
    array.rawView().withUnsafeBytes { pointer, _, _ in Data(bytes: pointer, count: count) }
}
func queueFence(_ queue: any MTLCommandQueue, _ label: String) throws {
    guard let command = queue.makeCommandBuffer() else { throw IsolationError.failed("fence allocation") }
    command.label = "large-output-isolation-\(label)"
    command.commit()
    command.waitUntilCompleted()
    let error: Any = command.error.map { error in
        let ns = error as NSError
        return ["domain": ns.domain, "code": ns.code, "description": ns.localizedDescription] as [String: Any]
    } ?? NSNull()
    event(["event": "queue_fence", "label": label, "status": command.status.rawValue, "error": error])
    try require(command.status == .completed && command.error == nil, "fence failed: \(label)")
}
func readyDrain(_ stream: ComputeStream, _ queue: any MTLCommandQueue, _ label: String) async throws {
    await stream.currentWorkCompleted()
    event(["event": "stream_complete", "label": label])
    try queueFence(queue, label)
}
func fillArray(_ array: inout NDArray, _ bytes: Int) {
    array.mutableRawView().withUnsafeMutableBytes { pointer, _, _ in
        for offset in stride(from: 0, to: bytes, by: blockBytes) {
            pattern(offset / blockBytes, 1).withUnsafeBytes { source in
                pointer.advanced(by: offset).copyMemory(
                    from: source.baseAddress!, byteCount: min(blockBytes, bytes - offset))
            }
        }
    }
}
func arrayAutomatic(_ function: InferenceFunction, _ input: consuming NDArray,
                    _ shape: [Int], _ bytes: Int, _ factor: Float, _ label: String,
                    _ stream: ComputeStream, _ queue: any MTLCommandQueue) async throws
                    -> (NDArray, [String: Any]) {
    // Exact installed public constructor: init(_ ndArray: consuming NDArray).
    // AsyncValue owns its input throughout submission, completion and error drain.
    let argument = InferenceFunction.AsyncValue(input)
    do {
        event(["event": "encode_begin", "label": label])
        var values = try function.encode(inputs: ["x": argument], to: stream)
        event(["event": "encode_returned", "label": label])
        try await readyDrain(stream, queue, "\(label)-before-readiness")
        guard let future = values.removeValue(forKey: "y"), let array = try await future.ndArray else {
            throw IsolationError.failed("missing automatic NDArray")
        }
        event(["event": "throwing_readiness_complete", "label": label])
        try await readyDrain(stream, queue, "\(label)-after-readiness")
        try checkMetadata(array, shape)
        let snapshot = arraySnapshot(array, bytes)
        event(["event": "snapshot_complete", "label": label, "bytes": snapshot.count])
        let hash = try verifySnapshot(snapshot, bytes, factor)
        return (array, ["label": label, "factor": factor, "sha256": hash,
                        "snapshot_source": "ready NDArray rawView, immediate full Data copy"])
    } catch {
        await stream.currentWorkCompleted()
        try? queueFence(queue, "\(label)-error-cleanup")
        throw error
    }
}
@main struct LargeInputMigrationIsolation {
    static func main() async {
        do { try await execute() }
        catch { event(["event": "failed", "error": String(describing: error)]); exit(1) }
    }
    static func execute() async throws {
        let args = CommandLine.arguments
        guard args.count == 5 else {
            throw IsolationError.failed("MODEL SHAPE ndarray-auto|ndarray-chain REPORT")
        }
        let shape = try args[2].split(separator: ",").map { value -> Int in
            guard let d = Int(value), d > 0 else { throw IsolationError.failed("positive dimensions only") }
            return d
        }
        try require(!shape.isEmpty && shape.count <= 64, "rank")
        var bytes = 4
        for dimension in shape {
            let product = bytes.multipliedReportingOverflow(by: dimension)
            try require(!product.overflow && product.partialValue <= 4_294_967_296, "4 GiB size limit")
            bytes = product.partialValue
        }
        let mode = args[3]
        try require(["ndarray-auto", "ndarray-chain"].contains(mode), "mode")
        guard let device = MTLCreateSystemDefaultDevice(), let queue = device.makeCommandQueue() else {
            throw IsolationError.failed("Metal device/queue")
        }
        let stream = ComputeStream(commandQueue: queue)
        let model = try await AIModel(contentsOf: URL(fileURLWithPath: args[1]),
                                      options: SpecializationOptions(preferredComputeUnitKind: .gpu))
        guard let function = try model.loadFunction(named: "main") else { throw IsolationError.failed("function") }
        // Match the failing run oracle's native allocation, mutableRawView fill,
        // complete input snapshot/verification, and finite nonzero capacity pattern.
        var input = NDArray(shape: shape, scalarType: .float32)
        fillArray(&input, bytes)
        let inputHash = try verifySnapshot(arraySnapshot(input, bytes), bytes, 1)
        event(["event": "input_verified", "mode": mode, "shape": shape, "bytes": bytes,
               "device": device.name, "maxBufferLength": device.maxBufferLength,
               "input_sha256": inputHash, "pattern_version": 2])
        let (first, firstResult) = try await arrayAutomatic(
            function, input, shape, bytes, 2, "ndarray-auto-first", stream, queue)
        var results = [firstResult]
        if mode == "ndarray-chain" {
            // Rewrap the ready owned first NDArray, rather than forwarding an
            // unresolved AsyncValue. Every actual producer has completed first.
            let (second, secondResult) = try await arrayAutomatic(
                function, first, shape, bytes, 4, "ndarray-auto-second", stream, queue)
            results.append(secondResult)
            withExtendedLifetime(second) {}
        }
        try await readyDrain(stream, queue, "final")
        let report: [String: Any] = ["passed": true, "mode": mode, "shape": shape, "bytes": bytes,
            "compute": "gpu-preferred", "pattern_version": 2, "input_sha256": inputHash,
            "results": results,
            "scope": "mechanical x+x NDArray input/migration isolation; no H3 generation qualification",
            "fence_limit": "empty command status describes this queue fence, not every internal CoreAI command buffer"]
        let data = try JSONSerialization.data(withJSONObject: report, options: [.sortedKeys, .prettyPrinted])
        try data.write(to: URL(fileURLWithPath: args[4]))
        print(String(decoding: data, as: UTF8.self))
        withExtendedLifetime(input) {}
        withExtendedLifetime(first) {}
        withExtendedLifetime(model) {}
    }
}
