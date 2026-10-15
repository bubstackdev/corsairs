import _Concurrency
@inline(never) public func yieldOnce() async { await Task.yield() }
@inline(never) public func yieldTwice() async { await Task.yield(); await Task.yield() }
@inline(never) public func sleepOnce() async throws { try await Task<Never, Never>.sleep(nanoseconds: 1_000_000) }
@inline(never) public func launchYield() -> Task<Void, Never> { Task.detached { await Task.yield() } }
