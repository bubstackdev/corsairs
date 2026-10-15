import CoreAI

@main
struct LoadOptionsOracle {
    static func main() {
        var cpu = SpecializationOptions.cpuOnly
        var gpu = SpecializationOptions(preferredComputeUnitKind: .gpu)
        let cpuDefault = cpu.expectFrequentReshapes
        let gpuDefault = gpu.expectFrequentReshapes
        cpu.expectFrequentReshapes = true
        gpu.expectFrequentReshapes = true
        let cpuTrue = cpu.expectFrequentReshapes
        let gpuTrue = gpu.expectFrequentReshapes
        cpu.expectFrequentReshapes = false
        gpu.expectFrequentReshapes = false
        let cpuFalse = cpu.expectFrequentReshapes
        let gpuFalse = gpu.expectFrequentReshapes
        print("{\"cpu_default\":\(cpuDefault),\"gpu_default\":\(gpuDefault),\"cpu_true\":\(cpuTrue),\"gpu_true\":\(gpuTrue),\"cpu_false\":\(cpuFalse),\"gpu_false\":\(gpuFalse)}")
    }
}
