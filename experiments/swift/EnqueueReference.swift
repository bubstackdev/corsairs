// Compiler oracle only; never linked into Corsairs.
import _Concurrency

// Runtime/Concurrency.h declares SWIFT_CC(swift) void(task, SerialExecutorRef).
@_silgen_name("swift_task_enqueueTaskOnExecutor")
func nativeEnqueue(_ task: UnsafeMutableRawPointer, _ executor: UnownedSerialExecutor)

@inline(never)
public func enqueueReference(_ task: UnsafeMutableRawPointer, _ executor: UnownedSerialExecutor) {
    nativeEnqueue(task, executor)
}

@inline(never)
public func detachedReference(_ operation: @escaping @Sendable () async -> Void) -> Task<Void, Never> {
    Task.detached(operation: operation)
}
