// Compiler-only task lifecycle oracle. It is not linked into Corsairs.
@inline(never)
public func startVoidTask() {
    _ = Task.detached { () }
}

@inline(never)
public func waitVoidTask(_ task: Task<Void, Never>) async {
    await task.value
}

@inline(never)
public func taskReturn() async { () }

@inline(never)
public func taskThrowingReturn() async throws { () }
