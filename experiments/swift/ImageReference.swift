import CoreAI
import CoreVideo
import Foundation
import IOSurface
import Metal

// Calibrates image/pixel-buffer I/O. Each @inline(never) wrapper calls one SDK
// entry point so `-emit-ir` shows its swiftcc signature; the run mode loads each
// model under a directory, feeds deterministic pixel buffers through `run` and
// `encode` per compute preference, and prints exact output bytes as JSON.
//
//   xcrun swiftc -parse-as-library -O -module-cache-path target/image/module-cache \
//       -emit-ir experiments/swift/ImageReference.swift -o target/image/image.ll
//   xcrun swiftc -parse-as-library -O -module-cache-path target/image/module-cache \
//       experiments/swift/ImageReference.swift -o target/image/image-oracle
//   target/image/image-oracle MODELS_DIR > oracle.json

// MARK: Descriptor accessors

@inline(never) public func imageDescriptor(_ d: consuming InferenceValue.Descriptor) -> ImageDescriptor? {
    switch consume d {
    case .image(let image): return image
    case .ndArray: return nil
    @unknown default: return nil
    }
}
@inline(never) public func imageWidth(_ d: borrowing ImageDescriptor) -> Int { d.width }
@inline(never) public func imageHeight(_ d: borrowing ImageDescriptor) -> Int { d.height }
@inline(never) public func imageFormat(_ d: borrowing ImageDescriptor) -> OSType { d.pixelFormatType }

// MARK: Pixel-buffer wrappers

@inline(never) public func mutableBuffer(_ buffer: sending CVPixelBuffer) -> CVMutablePixelBuffer {
    CVMutablePixelBuffer(unsafeBuffer: buffer)
}
@inline(never) public func readOnlyBuffer(_ buffer: sending CVPixelBuffer) -> CVReadOnlyPixelBuffer {
    CVReadOnlyPixelBuffer(unsafeBuffer: buffer)
}
@inline(never) public func freeze(_ buffer: consuming CVMutablePixelBuffer) -> CVReadOnlyPixelBuffer {
    CVReadOnlyPixelBuffer(buffer)
}
@inline(never) public func unwrapMutable(_ buffer: borrowing CVMutablePixelBuffer) -> CVPixelBuffer {
    buffer.withUnsafeBuffer { $0 }
}
@inline(never) public func unwrapReadOnly(_ buffer: borrowing CVReadOnlyPixelBuffer) -> CVPixelBuffer {
    buffer.withUnsafeBuffer { $0 }
}

// MARK: Value construction and readback

@inline(never) public func insertImage(_ buffer: borrowing CVReadOnlyPixelBuffer, _ name: borrowing String) {
    var inputs = InferenceFunction.Inputs()
    inputs.insert(buffer, for: name)
}
@inline(never) public func insertMutableInput(_ buffer: borrowing CVMutablePixelBuffer, _ name: borrowing String) {
    var inputs = InferenceFunction.Inputs()
    inputs.insert(buffer, for: name)
}
@inline(never) public func insertMutableImage(_ buffer: inout CVMutablePixelBuffer, _ name: borrowing String) {
    var views = InferenceFunction.MutableViews()
    views.insert(&buffer, for: name)
}
@inline(never) public func valueKind(_ value: borrowing InferenceValue) -> InferenceValue.Kind { value.kind }
@inline(never) public func valuePixelBuffer(_ value: consuming InferenceValue) -> CVMutablePixelBuffer? {
    value.pixelBuffer
}
@inline(never) public func imageValue(_ buffer: consuming CVMutablePixelBuffer) -> InferenceValue {
    InferenceValue(buffer)
}
@inline(never) public func asyncImageInput(_ buffer: CVReadOnlyPixelBuffer) -> InferenceFunction.AsyncValue {
    InferenceFunction.AsyncValue(buffer)
}
@inline(never) public func asyncImageOutput(_ buffer: consuming CVMutablePixelBuffer) -> InferenceFunction.AsyncMutableValue {
    InferenceFunction.AsyncMutableValue(buffer)
}
@inline(never) public func asyncPixelBuffer(_ value: InferenceFunction.AsyncValue) async throws -> CVReadOnlyPixelBuffer? {
    try await value.pixelBuffer
}
@inline(never) public func isImageKind(_ kind: InferenceValue.Kind) -> Bool { kind == .image }

// MARK: Oracle

func fourcc(_ value: OSType) -> String {
    let bytes = [24, 16, 8, 0].map { UInt8((value >> UInt32($0)) & 0xff) }
    if bytes.allSatisfy({ $0 >= 0x20 && $0 < 0x7f }) { return String(decoding: bytes, as: UTF8.self) }
    return String(format: "0x%08x", value)
}

let formats: [String: OSType] = [
    "RGB24": kCVPixelFormatType_24RGB, "ARGB32": kCVPixelFormatType_32ARGB,
    "BGRA32": kCVPixelFormatType_32BGRA, "YpCbCr8420Planar": kCVPixelFormatType_420YpCbCr8Planar,
]

func describe(_ d: InferenceValue.Descriptor?) -> Any {
    guard let d else { return NSNull() }
    switch d {
    case .ndArray(let nd): return ["kind": "ndArray", "shape": nd.shape, "scalar": String(describing: nd.scalarType)]
    case .image(let image):
        return ["kind": "image", "width": imageWidth(image), "height": imageHeight(image),
                "pixel_format": imageFormat(image), "fourcc": fourcc(imageFormat(image))]
    @unknown default: return ["kind": "unknown"]
    }
}

/// Planes as (width, height, bytes per pixel); packed formats have one plane.
func planes(_ format: OSType, _ width: Int, _ height: Int) -> [(Int, Int, Int)] {
    switch format {
    case kCVPixelFormatType_24RGB: [(width, height, 3)]
    case kCVPixelFormatType_420YpCbCr8Planar: [(width, height, 1), (width / 2, height / 2, 1), (width / 2, height / 2, 1)]
    default: [(width, height, 4)]
    }
}

/// Deterministic tight bytes per plane; never 0 or 255 so inversion is visible.
func pattern(_ format: OSType, _ width: Int, _ height: Int) -> [UInt8] {
    var bytes: [UInt8] = []
    for (p, (w, h, bpp)) in planes(format, width, height).enumerated() {
        for y in 0..<h { for x in 0..<w { for c in 0..<bpp {
            bytes.append(UInt8(1 + (p * 61 + y * 37 + x * 11 + c * 3) % 253))
        } } }
    }
    return bytes
}

func create(_ format: OSType, _ width: Int, _ height: Int, ioSurface: Bool) -> (CVPixelBuffer?, CVReturn) {
    var attributes: [String: Any] = [:]
    if ioSurface { attributes[kCVPixelBufferIOSurfacePropertiesKey as String] = [String: Any]() }
    var buffer: CVPixelBuffer?
    let status = CVPixelBufferCreate(nil, width, height, format, attributes as CFDictionary, &buffer)
    return (buffer, status)
}

func planeInfo(_ buffer: CVPixelBuffer) -> [(base: UnsafeMutableRawPointer?, rowBytes: Int, width: Int, height: Int)] {
    if CVPixelBufferIsPlanar(buffer) {
        return (0..<CVPixelBufferGetPlaneCount(buffer)).map {
            (CVPixelBufferGetBaseAddressOfPlane(buffer, $0), CVPixelBufferGetBytesPerRowOfPlane(buffer, $0),
             CVPixelBufferGetWidthOfPlane(buffer, $0), CVPixelBufferGetHeightOfPlane(buffer, $0))
        }
    }
    return [(CVPixelBufferGetBaseAddress(buffer), CVPixelBufferGetBytesPerRow(buffer),
             CVPixelBufferGetWidth(buffer), CVPixelBufferGetHeight(buffer))]
}

func fill(_ buffer: CVPixelBuffer, _ bytes: [UInt8]) {
    CVPixelBufferLockBaseAddress(buffer, [])
    defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
    let layout = planes(CVPixelBufferGetPixelFormatType(buffer), CVPixelBufferGetWidth(buffer), CVPixelBufferGetHeight(buffer))
    var offset = 0
    for (plane, (w, h, bpp)) in zip(planeInfo(buffer), layout) {
        for y in 0..<h {
            let row = plane.base!.advanced(by: y * plane.rowBytes)
            bytes.withUnsafeBytes { row.copyMemory(from: $0.baseAddress!.advanced(by: offset), byteCount: w * bpp) }
            offset += w * bpp
        }
    }
}

func inspect(_ buffer: CVPixelBuffer) -> [String: Any] {
    CVPixelBufferLockBaseAddress(buffer, .readOnly)
    defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
    let format = CVPixelBufferGetPixelFormatType(buffer)
    let width = CVPixelBufferGetWidth(buffer), height = CVPixelBufferGetHeight(buffer)
    var tight: [UInt8] = []
    var rows: [[String: Int]] = []
    for (plane, (w, h, bpp)) in zip(planeInfo(buffer), planes(format, width, height)) {
        rows.append(["bytes_per_row": plane.rowBytes, "width": plane.width, "height": plane.height])
        for y in 0..<h {
            let row = plane.base!.advanced(by: y * plane.rowBytes).assumingMemoryBound(to: UInt8.self)
            tight.append(contentsOf: UnsafeBufferPointer(start: row, count: w * bpp))
        }
    }
    return ["pixel_format": format, "fourcc": fourcc(format), "width": width, "height": height,
            "planar": CVPixelBufferIsPlanar(buffer), "planes": rows,
            "io_surface": CVPixelBufferGetIOSurface(buffer) != nil,
            "data_size": CVPixelBufferGetDataSize(buffer), "bytes": tight]
}

func tensorBytes(_ array: NDArray) -> [String: Any] {
    // Every tensor in these models is contiguous uint8 (one byte per element).
    let count = array.shape.reduce(1, *)
    let bytes = array.rawView().withUnsafeBytes { start, _, _ in
        Array(UnsafeRawBufferPointer(start: start, count: count))
    }
    return ["shape": array.shape, "strides": array.strides, "scalar": String(describing: array.scalarType), "bytes": bytes]
}

func error(_ error: any Error) -> [String: Any] {
    ["outcome": "threw", "error_type": _typeName(type(of: error), qualified: true), "description": String(describing: error)]
}

func readValue(_ value: consuming InferenceValue) -> [String: Any] {
    let kind = valueKind(value)
    if isImageKind(kind) {
        let buffer = valuePixelBuffer(value)
        switch consume buffer {
        case .some(let buffer): return ["kind": "image", "buffer": inspect(unwrapMutable(buffer))]
        case .none: return ["kind": "image", "buffer": NSNull()]
        }
    }
    guard let array = value.ndArray else { return ["kind": "ndArray", "array": NSNull()] }
    return ["kind": "ndArray", "array": tensorBytes(array)]
}

struct Case {
    let name: String, input: String, output: String
    let inputImage: (OSType, Int, Int)?, outputImage: (OSType, Int, Int)?
    let inputShape: [Int]?
}

func signature(_ function: InferenceFunction) -> Case? {
    let d = function.descriptor
    guard d.inputNames.count == 1, d.outputNames.count == 1 else { return nil }
    let input = d.inputNames[0], output = d.outputNames[0]
    var inImage: (OSType, Int, Int)?, outImage: (OSType, Int, Int)?, shape: [Int]?
    switch d.inputDescriptor(of: input)! {
    case .image(let i): inImage = (i.pixelFormatType, i.width, i.height)
    case .ndArray(let n): shape = n.shape
    @unknown default: return nil
    }
    if case .image(let i) = d.outputDescriptor(of: output)! { outImage = (i.pixelFormatType, i.width, i.height) }
    return Case(name: d.name, input: input, output: output, inputImage: inImage, outputImage: outImage, inputShape: shape)
}

/// The tight bytes that every model in models.json should return: image_to_tensor
/// and identity copy the input; invert subtracts it from 255.
func expected(_ model: String, _ input: [UInt8]) -> [UInt8] {
    model.contains("invert") ? input.map { 255 - $0 } : input
}

func inputBytes(_ c: Case) -> [UInt8] {
    if let (format, width, height) = c.inputImage { return pattern(format, width, height) }
    // Tensor inputs carry the same tight bytes as the matching image; the
    // tensor-only control ([height, width, 4]) uses the BGRA pattern.
    if let (format, width, height) = c.outputImage { return pattern(format, width, height) }
    return pattern(kCVPixelFormatType_32BGRA, c.inputShape![1], c.inputShape![0])
}

func execute(_ function: InferenceFunction, _ inputs: borrowing InferenceFunction.Inputs, _ c: Case,
             outputView: Bool, viewIOSurface: Bool, _ row: inout [String: Any]) async throws {
    var targetRef: CVPixelBuffer?
    var outputs: InferenceFunction.Outputs
    if outputView, let (format, width, height) = c.outputImage {
        let (buffer, _) = create(format, width, height, ioSurface: viewIOSurface)
        targetRef = buffer
        var target = mutableBuffer(buffer!)
        var views = InferenceFunction.MutableViews()
        views.insert(&target, for: c.output)
        trace("  run with output view")
        outputs = try await function.run(inputs: inputs, outputViews: views)
    } else {
        trace("  run")
        outputs = try await function.run(inputs: inputs)
    }
    trace("  run returned")
    row["returned_count"] = outputs.count
    if let value = outputs.remove(c.output) {
        let read = readValue(value)
        row["returned"] = read
        if let buffer = read["buffer"] as? [String: Any] { row["actual"] = buffer["bytes"] }
        if let tensor = read["array"] as? [String: Any] { row["actual"] = tensor["bytes"] }
    } else {
        row["returned"] = NSNull()
    }
    if let targetRef {
        let view = inspect(targetRef)
        row["output_view_buffer"] = view
        if row["actual"] == nil { row["actual"] = view["bytes"] }
    }
}

func runOnce(_ function: InferenceFunction, _ c: Case, model: String, ioSurface: Bool, outputView: Bool,
             inputOverride: (OSType, Int, Int)? = nil, mutableInput: Bool = false,
             viewIOSurface: Bool = true) async -> [String: Any] {
    var row: [String: Any] = ["io_surface_input": ioSurface, "output_view": outputView,
                              "mutable_input": mutableInput, "io_surface_view": viewIOSurface]
    let bytes = inputBytes(c)
    do {
        if let (format, width, height) = inputOverride ?? c.inputImage {
            let (buffer, status) = create(format, width, height, ioSurface: ioSurface)
            guard let buffer else { return ["outcome": "create_failed", "cv_return": status] }
            fill(buffer, inputOverride == nil ? bytes : pattern(format, width, height))
            row["input_buffer"] = inspect(buffer).filter { $0.key != "bytes" }
            if mutableInput {
                // CVMutablePixelBuffer is also ViewRepresentable: the struct wrapper
                // avoids constructing the CVReadOnlyPixelBuffer class from Rust.
                let source = mutableBuffer(buffer)
                var inputs = InferenceFunction.Inputs()
                trace("  insert mutable image")
                inputs.insert(source, for: c.input)
                try await execute(function, inputs, c, outputView: outputView, viewIOSurface: viewIOSurface, &row)
            } else {
                let source = readOnlyBuffer(buffer)
                var inputs = InferenceFunction.Inputs()
                trace("  insert image")
                inputs.insert(source, for: c.input)
                try await execute(function, inputs, c, outputView: outputView, viewIOSurface: viewIOSurface, &row)
            }
        } else {
            var array = NDArray(shape: c.inputShape!, scalarType: .uint8)
            array.mutableRawView().withUnsafeMutableBytes { destination, _, _ in
                bytes.withUnsafeBytes { destination.copyMemory(from: $0.baseAddress!, byteCount: $0.count) }
            }
            var inputs = InferenceFunction.Inputs()
            inputs.insert(array.rawView(), for: c.input)
            try await execute(function, inputs, c, outputView: outputView, viewIOSurface: viewIOSurface, &row)
        }
        row["outcome"] = "completed"
        row["exact"] = (row["actual"] as? [UInt8]) == expected(model, bytes)
    } catch let e {
        row.merge(error(e)) { $1 }
    }
    return row
}

func encodeOnce(_ function: InferenceFunction, _ c: Case, model: String,
                outputView: Bool = false, ioSurface: Bool = true) async -> [String: Any] {
    var row: [String: Any] = ["output_view": outputView, "io_surface": ioSurface]
    let bytes = inputBytes(c)
    do {
        var inputs: [String: InferenceFunction.AsyncValue] = [:]
        if let (format, width, height) = c.inputImage {
            let (buffer, _) = create(format, width, height, ioSurface: ioSurface)
            fill(buffer!, bytes)
            inputs[c.input] = asyncImageInput(readOnlyBuffer(buffer!))
        } else {
            var value = NDArray(shape: c.inputShape!, scalarType: .uint8)
            value.mutableRawView().withUnsafeMutableBytes { destination, _, _ in
                bytes.withUnsafeBytes { destination.copyMemory(from: $0.baseAddress!, byteCount: $0.count) }
            }
            inputs[c.input] = InferenceFunction.AsyncValue(value)
        }
        let stream = ComputeStream(commandQueue: MTLCreateSystemDefaultDevice()!.makeCommandQueue()!)
        if outputView, let (format, width, height) = c.outputImage {
            // Caller-allocated destination: CVMutablePixelBuffer -> AsyncMutableValue.
            let (buffer, _) = create(format, width, height, ioSurface: ioSurface)
            var target = asyncImageOutput(mutableBuffer(buffer!))
            var views = InferenceFunction.AsyncMutableViews()
            views.insert(&target, for: c.output)
            let outputs = try function.encode(inputs: inputs, outputViews: views, to: stream)
            await stream.currentWorkCompleted()
            row["returned_count"] = outputs.count
            let view = inspect(buffer!)
            row["output_view_buffer"] = view
            row["actual"] = view["bytes"]
            row["outcome"] = "completed"
            row["exact"] = (row["actual"] as? [UInt8]) == expected(model, bytes)
            return row
        }
        var outputs = try function.encode(inputs: inputs, to: stream)
        await stream.currentWorkCompleted()
        guard let value = outputs.removeValue(forKey: c.output) else { return ["outcome": "missing_output"] }
        if c.outputImage != nil {
            guard let buffer = try await asyncPixelBuffer(value) else { return ["outcome": "no_pixel_buffer"] }
            let read = inspect(unwrapReadOnly(buffer))
            row["returned"] = read
            row["actual"] = read["bytes"]
        } else {
            let array = try await value.ndArray!
            row["returned"] = tensorBytes(array)
            row["actual"] = tensorBytes(array)["bytes"]
        }
        await stream.currentWorkCompleted()
        row["outcome"] = "completed"
        row["exact"] = (row["actual"] as? [UInt8]) == expected(model, bytes)
    } catch let e {
        row.merge(error(e)) { $1 }
    }
    return row
}

/// IMAGE_ORACLE_TRACE=1 logs each step to stderr, so a trap names its step.
/// IMAGE_ORACLE_SKIP=a,b skips named cases (for example a case that traps).
/// IMAGE_ORACLE_BACKENDS=gpu,neural_engine restricts the backends.
let environment = ProcessInfo.processInfo.environment
let skipped = Set((environment["IMAGE_ORACLE_SKIP"] ?? "").split(separator: ",").map(String.init))
let selectedBackends = (environment["IMAGE_ORACLE_BACKENDS"] ?? "cpu_only,gpu,neural_engine").split(separator: ",").map(String.init)
func trace(_ message: String) {
    if environment["IMAGE_ORACLE_TRACE"] != nil { FileHandle.standardError.write(Data((message + "\n").utf8)) }
}

func attempt(_ name: String, _ model: String, _ backend: String, _ result: inout [String: Any],
             _ body: () async -> [String: Any]) async {
    if skipped.contains(name) || skipped.contains("\(model):\(name)") {
        result[name] = ["outcome": "skipped"]
        return
    }
    trace("\(model) \(backend) \(name)")
    result[name] = await body()
}

func compute(_ name: String) -> SpecializationOptions {
    switch name {
    case "cpu_only": .cpuOnly
    case "gpu": SpecializationOptions(preferredComputeUnitKind: .gpu)
    default: SpecializationOptions(preferredComputeUnitKind: .neuralEngine)
    }
}

func report(_ directory: URL, _ model: String) async -> [String: Any] {
    var row: [String: Any] = ["model": model]
    let url = directory.appendingPathComponent(model).appendingPathComponent("model.aimodel")
    var backends: [String: Any] = [:]
    for backend in selectedBackends {
        var result: [String: Any] = [:]
        do {
            let loaded = try await AIModel(contentsOf: url, options: compute(backend))
            let function = try loaded.loadFunction(named: "main")!
            let d = function.descriptor
            row["descriptor"] = [
                "inputs": Dictionary(uniqueKeysWithValues: d.inputNames.map { ($0, describe(d.inputDescriptor(of: $0))) }),
                "outputs": Dictionary(uniqueKeysWithValues: d.outputNames.map { ($0, describe(d.outputDescriptor(of: $0))) }),
            ]
            guard let c = signature(function) else { result["outcome"] = "unsupported_signature"; backends[backend] = result; continue }
            await attempt("run_io_surface", model, backend, &result) {
                await runOnce(function, c, model: model, ioSurface: true, outputView: false)
            }
            await attempt("run_memory", model, backend, &result) {
                await runOnce(function, c, model: model, ioSurface: false, outputView: false)
            }
            if c.inputImage != nil {
                await attempt("run_mutable_input", model, backend, &result) {
                    await runOnce(function, c, model: model, ioSurface: true, outputView: false, mutableInput: true)
                }
            }
            if c.outputImage != nil {
                await attempt("run_output_view", model, backend, &result) {
                    await runOnce(function, c, model: model, ioSurface: true, outputView: true)
                }
                await attempt("run_output_view_memory", model, backend, &result) {
                    await runOnce(function, c, model: model, ioSurface: false, outputView: true,
                                  mutableInput: c.inputImage != nil, viewIOSurface: false)
                }
            }
            if let (format, width, height) = c.inputImage {
                let other = format == kCVPixelFormatType_32BGRA ? kCVPixelFormatType_32ARGB : kCVPixelFormatType_32BGRA
                await attempt("run_wrong_format", model, backend, &result) {
                    await runOnce(function, c, model: model, ioSurface: true, outputView: false,
                                  inputOverride: (other, width, height))
                }
                await attempt("run_wrong_size", model, backend, &result) {
                    await runOnce(function, c, model: model, ioSurface: true, outputView: false,
                                  inputOverride: (format, width + 2, height))
                }
            }
            if backend != "cpu_only" {
                await attempt("encode", model, backend, &result) { await encodeOnce(function, c, model: model) }
                if c.outputImage != nil {
                    await attempt("encode_output_view", model, backend, &result) {
                        await encodeOnce(function, c, model: model, outputView: true)
                    }
                    await attempt("encode_output_view_memory", model, backend, &result) {
                        await encodeOnce(function, c, model: model, outputView: true, ioSurface: false)
                    }
                }
            }
        } catch let e {
            result["load"] = error(e)
        }
        backends[backend] = result
    }
    row["backends"] = backends
    return row
}

func residentBytes() -> UInt64 {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / MemoryLayout<natural_t>.size)
    let status = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
            task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
        }
    }
    return status == KERN_SUCCESS ? info.resident_size : 0
}

/// IMAGE_ORACLE_SOAK=N: N image-in/image-out runs of one model per backend with
/// a fresh input buffer and output view each time, sampling RSS. Measures
/// whether the pixel-buffer path leaks or needs an autorelease pool.
func soak(_ directory: URL, _ model: String, _ iterations: Int) async throws -> [String: Any] {
    var rows: [String: Any] = [:]
    for backend in selectedBackends {
        let url = directory.appendingPathComponent(model).appendingPathComponent("model.aimodel")
        let loaded = try await AIModel(contentsOf: url, options: compute(backend))
        let function = try loaded.loadFunction(named: "main")!
        let c = signature(function)!
        var samples: [[String: Any]] = []
        var failures = 0
        for i in 0...iterations {
            if i % max(1, iterations / 10) == 0 { samples.append(["iteration": i, "rss": residentBytes()]) }
            if i == iterations { break }
            let row = await runOnce(function, c, model: model, ioSurface: true, outputView: true, mutableInput: true)
            if row["exact"] as? Bool != true { failures += 1 }
        }
        rows[backend] = ["iterations": iterations, "inexact_or_failed": failures, "rss_samples": samples]
    }
    return rows
}

@main struct ImageOracle {
    static func main() async throws {
        if let count = environment["IMAGE_ORACLE_SOAK"].flatMap(Int.init) {
            let directory = URL(fileURLWithPath: CommandLine.arguments[1])
            let model = CommandLine.arguments[2]
            let output: [String: Any] = ["model": model, "soak": try await soak(directory, model, count)]
            let bytes = try JSONSerialization.data(withJSONObject: output, options: [.sortedKeys, .prettyPrinted])
            print(String(decoding: bytes, as: UTF8.self))
            return
        }
        let directory = URL(fileURLWithPath: CommandLine.arguments[1])
        let manifest = try JSONSerialization.jsonObject(with: Data(contentsOf: directory.appendingPathComponent("models.json"))) as! [String: Any]
        let names = (manifest["models"] as! [[String: Any]]).filter { $0["authored"] as! Bool }.map { $0["name"] as! String }
        let only = CommandLine.arguments.dropFirst(2)
        var rows: [[String: Any]] = []
        for name in names where only.isEmpty || only.contains(name) { rows.append(await report(directory, name)) }
        let output: [String: Any] = [
            "device_architecture": AIModel.deviceArchitectureName,
            "constants": formats.mapValues { ["pixel_format": $0, "fourcc": fourcc($0)] },
            "models": rows,
        ]
        let bytes = try JSONSerialization.data(withJSONObject: output, options: [.sortedKeys, .prettyPrinted])
        print(String(decoding: bytes, as: UTF8.self))
    }
}
