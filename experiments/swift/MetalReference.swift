import CoreAI
import Metal

@inline(never)
public func makeStream(_ queue: consuming any MTLCommandQueue) -> ComputeStream {
    ComputeStream(commandQueue: queue)
}

@inline(never)
public func inputBuffer(_ buffer: consuming any MTLBuffer,
                        _ scalar: consuming NDArray.ScalarType,
                        _ shape: [Int]) -> InferenceFunction.AsyncValue {
    InferenceFunction.AsyncValue(unsafeBuffer: buffer, scalarType: scalar, shape: shape)
}

@inline(never)
public func outputBuffer(_ buffer: consuming any MTLBuffer,
                         _ scalar: consuming NDArray.ScalarType,
                         _ shape: [Int]) -> InferenceFunction.AsyncMutableValue {
    InferenceFunction.AsyncMutableValue(unsafeBuffer: buffer, scalarType: scalar, shape: shape)
}

@inline(never)
public func arrayInput(_ array: consuming NDArray) -> InferenceFunction.AsyncValue {
    InferenceFunction.AsyncValue(array)
}

@inline(never)
public func arrayOutput(_ array: consuming NDArray) -> InferenceFunction.AsyncMutableValue {
    InferenceFunction.AsyncMutableValue(array)
}

@inline(never)
public func encode(_ function: borrowing InferenceFunction,
                   _ inputs: [String: InferenceFunction.AsyncValue],
                   _ output: inout InferenceFunction.AsyncMutableValue,
                   _ name: String, _ stream: ComputeStream) throws -> [String: InferenceFunction.AsyncValue] {
    var views = InferenceFunction.AsyncMutableViews()
    views.insert(&output, for: name)
    return try function.encode(inputs: inputs, outputViews: views, to: stream)
}

@inline(never)
public func encodeBoth(_ function: borrowing InferenceFunction,
                       _ inputs: [String: InferenceFunction.AsyncValue],
                       _ state: inout InferenceFunction.AsyncMutableValue,
                       _ stateName: String,
                       _ output: inout InferenceFunction.AsyncMutableValue,
                       _ outputName: String, _ stream: ComputeStream) throws -> [String: InferenceFunction.AsyncValue] {
    var states = InferenceFunction.AsyncMutableViews()
    var outputs = InferenceFunction.AsyncMutableViews()
    states.insert(&state, for: stateName)
    outputs.insert(&output, for: outputName)
    return try function.encode(inputs: inputs, states: states, outputViews: outputs, to: stream)
}

@inline(never)
public func drain(_ stream: ComputeStream) async {
    await stream.currentWorkCompleted()
}

@inline(never)
public func readyInput(_ value: InferenceFunction.AsyncValue) async throws -> NDArray? {
    try await value.ndArray
}

@inline(never)
public func readyOutput(_ value: consuming InferenceFunction.AsyncMutableValue) async throws -> NDArray? {
    try await value.ndArray
}

@inline(never)
public func emptyInputs() -> [String: InferenceFunction.AsyncValue] { Dictionary() }

@inline(never)
public func insertInput(_ inputs: inout [String: InferenceFunction.AsyncValue],
                        _ value: InferenceFunction.AsyncValue, _ name: String) {
    inputs[name] = value
}

@inline(never)
public func removeOutput(_ outputs: inout [String: InferenceFunction.AsyncValue],
                         _ name: String) -> InferenceFunction.AsyncValue? {
    outputs.removeValue(forKey: name)
}

@inline(never)
public func dictionaryMetadata<Key: Hashable, Value>(_ key: Key.Type, _ value: Value.Type) -> Any.Type {
    Dictionary<Key, Value>.self
}

@inline(never)
public func discardInputs(_ inputs: consuming [String: InferenceFunction.AsyncValue]) {}

@inline(never)
public func defaultDevice() -> (any MTLDevice)? { MTLCreateSystemDefaultDevice() }

@inline(never)
public func commandQueue(_ device: any MTLDevice) -> (any MTLCommandQueue)? { device.makeCommandQueue() }

@inline(never)
public func sharedBuffer(_ device: any MTLDevice, _ count: Int) -> (any MTLBuffer)? {
    device.makeBuffer(length: count, options: .storageModeShared)
}

@inline(never)
public func commandBuffer(_ queue: any MTLCommandQueue) -> (any MTLCommandBuffer)? { queue.makeCommandBuffer() }

@inline(never)
public func contents(_ buffer: any MTLBuffer) -> UnsafeMutableRawPointer { buffer.contents() }

@inline(never)
public func length(_ buffer: any MTLBuffer) -> Int { buffer.length }

@inline(never)
public func commitAndWait(_ command: any MTLCommandBuffer) {
    command.commit()
    command.waitUntilCompleted()
}
