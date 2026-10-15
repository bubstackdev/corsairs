import CoreAI

@inline(never)
public func setFrequentReshapes(_ options: inout SpecializationOptions, _ enabled: Bool) {
    options.expectFrequentReshapes = enabled
}

@inline(never)
public func frequentReshapes(_ options: borrowing SpecializationOptions) -> Bool {
    options.expectFrequentReshapes
}

@inline(never)
public func cpuOptions() -> SpecializationOptions {
    .cpuOnly
}

@inline(never)
public func gpuOptions() -> SpecializationOptions {
    SpecializationOptions(preferredComputeUnitKind: .gpu)
}
