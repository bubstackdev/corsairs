import Metal

@inline(never)
public func queueDevice(_ queue: any MTLCommandQueue) -> any MTLDevice { queue.device }

@inline(never)
public func bufferDevice(_ buffer: any MTLBuffer) -> any MTLDevice { buffer.device }

@inline(never)
public func storageMode(_ buffer: any MTLBuffer) -> UInt { buffer.storageMode.rawValue }

@inline(never)
public func commandStatus(_ command: any MTLCommandBuffer) -> UInt { command.status.rawValue }
