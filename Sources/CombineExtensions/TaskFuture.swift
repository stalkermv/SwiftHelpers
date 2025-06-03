//
//  TaskFuture.swift
//  SwiftHelpers
//
//  Created by Valeriy Malishevskyi on 04.09.2024.
//

import Foundation
#if canImport(Combine)
import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public final class TaskFuture<Output, Failure: Error>: Publisher, Sendable {
    public typealias Promise = @Sendable (Result<Output, Failure>) -> Void

    private let work: @Sendable (Promise) async -> Void

    public init(_ work: @Sendable @escaping (Promise) async -> Void) {
        self.work = work
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input, S: Sendable {
        let subscription = TaskFutureSubscription(subscriber: subscriber, work: work)
        subscriber.receive(subscription: subscription)
    }
}

/// AsyncAwaitFuture.AsyncAwaitSubscription

private extension TaskFuture {
    final class TaskFutureSubscription<S: Subscriber>: Subscription
    where S.Input == Output, S.Failure == Failure, S: Sendable {
        private var subscriber: S?
        private let task: Task<Void, Error>

        init(subscriber: S, work: @Sendable @escaping (Promise) async -> Void) {
            self.subscriber = subscriber
            task = Task {
                await work { result in
                    switch result {
                    case .success(let output):
                        _ = subscriber.receive(output)
                        subscriber.receive(completion: .finished)
                    case .failure(let failure):
                        subscriber.receive(completion: .failure(failure))
                    }
                }
            }
        }

        func request(_ demand: Subscribers.Demand) { }

        func cancel() {
            subscriber = nil
            task.cancel()
        }
    }
}

extension TaskFuture where Failure == Error {
    convenience public init(operation: @escaping @Sendable () async throws -> Output) {
        self.init { promise in
            do {
                let output = try await operation()
                promise(.success(output))
            } catch {
                promise(.failure(error))
            }
        }
    }
}
#endif
