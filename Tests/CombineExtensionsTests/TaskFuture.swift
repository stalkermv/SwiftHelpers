//
//  TaskFuture.swift
//  SwiftHelpers
//
//  Created by Valeriy Malishevskyi on 02.05.2025.
//

import Testing
import Combine
@testable import CombineExtensions

struct TaskFutureTests {
    @Test @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    func successfulOperation() async throws {
        let future = TaskFuture<Int, Never> { promise in
            promise(.success(42))
        }
        
        for try await value in future.values {
            #expect(value == 42)
        }
    }
    
    @Test @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    func errorHandling() async throws {
        enum TestError: Error {
            case test
            case unexpectedValue
        }
        
        let future = TaskFuture<Int, TestError> { promise in
            promise(.failure(TestError.test))
        }
    
        await #expect(throws: TestError.test) {
            for try await _ in future.values {
                throw TestError.unexpectedValue // This should never be reached
            }
        }
    }
    
    @Test @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    func convenienceInitializer() async throws {
        let future = TaskFuture<Int, Error> { 
            return 42
        }
        
        for try await value in future.values {
            #expect(value == 42)
        }
    }
    
    @Test @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    func convenienceInitializerWithError() async throws {
        enum TestError: Error {
            case test
            case unexpectedValue
        }
        
        let future = TaskFuture<Int, Error> {
            throw TestError.test
        }
        
        await #expect(throws: TestError.test) {
            for try await _ in future.values {
                throw TestError.unexpectedValue // This should never be reached
            }
        }
    }
    
    @Test @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    func cancellation() async throws {
        let future = TaskFuture<Int, Error> { promise in
            try? await Task.sleep(for: .milliseconds(100))
            #expect(Task.isCancelled)
        }
        
        let cancellable = future.sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in }
        )
        
        // Cancel immediately
        cancellable.cancel()
        
        try await Task.sleep(for: .milliseconds(200))
    }
    
    @Test @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    func multipleSubscribers() async throws {
        let future = TaskFuture<Int, Never> { promise in
            try? await Task.sleep(for: .milliseconds(50))
            promise(.success(42))
        }
        
        let _ = future.sink(
            receiveCompletion: { _ in },
            receiveValue: {
                #expect($0 == 42)
            }
        )
        
        let _ = future.sink(
            receiveCompletion: { _ in },
            receiveValue: {
                #expect($0 == 42)
            }
        )
        
        try await Task.sleep(for: .milliseconds(100))
    }
}
