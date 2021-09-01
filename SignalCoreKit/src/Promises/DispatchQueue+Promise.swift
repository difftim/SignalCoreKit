//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

import Foundation

public enum PromiseNamespace { case promise }

public extension DispatchQueue {
    class var current: DispatchQueue { DispatchCurrentQueue() }
    func asyncIfNecessary(
        execute work: @escaping @convention(block) () -> Void
    ) {
        if self == Self.current {
            work()
        } else {
            async { work() }
        }
    }
    func async<T>(_ namespace: PromiseNamespace, execute work: @escaping () -> T) -> Guarantee<T> {
        let guarantee = Guarantee<T>()
        async {
            guarantee.resolve(work())
        }
        return guarantee
    }
    func async<T>(_ namespace: PromiseNamespace, execute work: @escaping () throws -> T) -> Promise<T> {
        let promise = Promise<T>()
        async {
            do {
                promise.resolve(try work())
            } catch {
                promise.reject(error)
            }
        }
        return promise
    }
}

public extension Optional where Wrapped == DispatchQueue {
    func asyncIfNecessary(
        execute work: @escaping @convention(block) () -> Void
    ) {
        switch self {
        case .some(let queue):
            queue.asyncIfNecessary(execute: work)
        case .none:
            work()
        }
    }
}
