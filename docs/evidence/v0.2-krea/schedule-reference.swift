// Reference tooling only: the Foundation/Float calculation from Krea's
// Sources/AetherDiffusion/FlowMatchSchedule.swift, with the fixed tower manifest.
// No CoreAI calls or application runtime wrapper.
import Foundation

let steps = 8
let start = 1.0
let stop = 1.0 / Double(steps)
let delta = (stop - start) / Double(steps - 1)
let exponent = Float(Foundation.exp(1.15))
var sigmas = (0..<steps).map { index -> Float in
    let base = Float(index == steps - 1 ? stop : Double(index) * delta + start)
    return exponent / (exponent + (1 / base - 1))
}
let timesteps = sigmas.map { $0 * Float(1000) / Float(1000) }
sigmas.append(0)
let differences = (0..<steps).map { sigmas[$0 + 1] - sigmas[$0] }
let result: [String: Any] = [
    "kind": "krea-fixed-tower-8-step-swift-schedule",
    "mu": 1.15,
    "sigma_bits": sigmas.map { $0.bitPattern },
    "timestep_bits": timesteps.map { $0.bitPattern },
    "delta_bits": differences.map { $0.bitPattern },
    "sigmas": sigmas.map(Double.init),
    "timesteps": timesteps.map(Double.init),
    "deltas": differences.map(Double.init)
]
let data = try JSONSerialization.data(withJSONObject: result, options: [.sortedKeys])
print(String(decoding: data, as: UTF8.self))
