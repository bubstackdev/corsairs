import CoreAI
import CryptoKit
import Darwin
import Foundation

// Independent ordinary Swift API diagnostic. No Rust/Corsairs linkage, Metal
// queue, huge buffer, or output binding. Input/output logical payloads are empty.
struct DiagnosticError: Error { let message: String }
func require(_ condition: Bool, _ message: String) throws {
    if !condition { throw DiagnosticError(message: message) }
}
func emit(_ fields: [String: Any]) {
    let bytes = try! JSONSerialization.data(withJSONObject: fields, options: [.sortedKeys])
    FileHandle.standardOutput.write(bytes)
    FileHandle.standardOutput.write(Data([10]))
}
func descriptorShape(_ value: consuming InferenceValue.Descriptor) throws -> [Int] {
    switch consume value {
    case .ndArray(let descriptor):
        try require(descriptor.scalarType == .float32, "descriptor dtype is not float32")
        return descriptor.shape
    case .image:
        throw DiagnosticError(message: "unexpected image descriptor")
    @unknown default:
        throw DiagnosticError(message: "unknown descriptor kind")
    }
}
@main struct EmptyBroadcastCPU {
    static func main() async {
        do { try await execute() }
        catch {
            emit(["event": "complete", "passed": false,
                  "error_type": _typeName(type(of: error), qualified: true),
                  "description": String(describing: error)])
            exit(1)
        }
    }
    static func execute() async throws {
        guard CommandLine.arguments.count == 2 else {
            throw DiagnosticError(message: "usage: empty-broadcast-cpu MODEL_ASSET")
        }
        let path = CommandLine.arguments[1]
        emit(["event": "start", "asset": path, "compute": "cpuOnly",
              "ordinary_swift_api": true, "corsairs_linked": false])
        let model = try await AIModel(contentsOf: URL(fileURLWithPath: path), options: .cpuOnly)
        emit(["event": "model_loaded", "functions": model.functionNames])
        guard let function = try model.loadFunction(named: "main") else {
            throw DiagnosticError(message: "missing main")
        }
        let descriptor = function.descriptor
        guard let x = descriptor.inputDescriptor(of: "x"),
              let y = descriptor.outputDescriptor(of: "y") else {
            throw DiagnosticError(message: "missing x/y descriptor")
        }
        let inputShape = try descriptorShape(x)
        let outputShape = try descriptorShape(y)
        emit(["event": "descriptor", "function": descriptor.name,
              "inputs": descriptor.inputNames, "outputs": descriptor.outputNames,
              "states": descriptor.stateNames, "input_shape": inputShape,
              "output_shape": outputShape, "dtype": "float32"])
        try require(inputShape == [0,1] && outputShape == [0,536870913], "wrong fixed asset")
        try require(descriptor.stateNames.isEmpty, "unexpected states")
        let input = NDArray(shape: [0,1], scalarType: .float32)
        emit(["event": "input_created", "shape": input.shape, "strides": input.strides,
              "is_float32": input.scalarType == .float32, "logical_bytes": 0])
        var inputs = InferenceFunction.Inputs()
        inputs.insert(input.rawView(), for: "x")
        emit(["event": "before_run", "execution": "try await function.run(inputs:)"])
        var outputs = try await function.run(inputs: inputs)
        emit(["event": "after_run", "output_count": outputs.count])
        guard let value = outputs.remove("y"), let output = value.ndArray else {
            throw DiagnosticError(message: "missing NDArray output y")
        }
        // Snapshot immediately on return, with an event on either side so a
        // native crash can be separated from metadata/readback access.
        emit(["event": "output_metadata", "shape": output.shape, "strides": output.strides,
              "is_float32": output.scalarType == .float32])
        try require(output.shape == [0,536870913] && output.scalarType == .float32,
                    "wrong output metadata")
        emit(["event": "before_zero_data_snapshot"])
        let captured = output.rawView().withUnsafeBytes { pointer, _, _ in
            Data(bytes: pointer, count: 0)
        }
        let digest = SHA256.hash(data: captured).map { String(format: "%02x", $0) }.joined()
        emit(["event": "output_snapshot", "bytes": captured.count, "sha256": digest])
        // The input stays alive through the asynchronous call and snapshot.
        withExtendedLifetime(input) {}
        try require(captured.isEmpty && outputs.count == 0, "unexpected output storage/arity")
        emit(["event": "complete", "passed": true, "logical_output_bytes": 0,
              "nonzero_output_extent_bytes": 2147483652])
    }
}
