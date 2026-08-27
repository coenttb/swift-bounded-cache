public import Async
public import Async_Waiter
public import Memory_Heap
public import Queue_Primitive

extension Cache.Entry {

    @usableFromInline

    final class Waiters: @unchecked Sendable {
        @usableFromInline
        var queue: Async.Waiter.Queue.Unbounded<Outcome, Void>

        @inlinable
        package init() {
            self.queue = Async.Waiter.Queue.Unbounded<Outcome, Void>()
        }
    }
}

extension Cache.Entry.Waiters {

    @usableFromInline
    typealias Outcome = Result<Value, any Swift.Error>

}
