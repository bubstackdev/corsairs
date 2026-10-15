import CoreAI
import Foundation

@inline(never)
public func makeTensor() -> NDArray {
    NDArray(shape: [4], scalarType: .float32)
}

@inline(never)
public func selectFunction(_ model: AIModel, _ name: String) throws -> InferenceFunction? {
    try model.loadFunction(named: name)
}

@inline(never)
public func loadModel(_ url: URL) async throws -> AIModel {
    try await AIModel(contentsOf: url)
}

@inline(never)
public func runModel(_ function: InferenceFunction, _ tensor: NDArray) async throws -> Int {
    let outputs = try await function.run(inputs: ["x": tensor])
    return outputs.count
}
