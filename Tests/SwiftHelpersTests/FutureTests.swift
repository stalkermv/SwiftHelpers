//
//  FutureTests.swift
//  
//
//  Created by Valeriy Malishevskyi on 01.05.2023.
//

import XCTest
import Combine
import SwiftHelpers

@available(iOS 15.0, *)
final class FutureTests: XCTestCase {
    
    enum TestError: Error {
        case testError
    }
    
    func testFutureSuccess() async throws {
        let expectedOutput = 42
        let future = Future<Int, Error> { promise in
            Task {
                promise(.success(expectedOutput))
            }
        }
        let output = try await future.value
        XCTAssertEqual(output, expectedOutput)
    }
    
    func testFutureFailure() async throws {
        let future = Future<Int, Error> { promise in
            Task {
                promise(.failure(TestError.testError))
            }
        }
        do {
            _ = try await future.value
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? TestError, TestError.testError)
        }
    }
    
    func testFutureFromOperationSuccess() async throws {
        let expectedOutput = 42
        let future = Future<Int, Error>(operation: {
            expectedOutput
        })
        let output = try await future.value
        XCTAssertEqual(output, expectedOutput)
    }
    
    func testFutureFromOperationFailure() async throws {
        let future = Future<Int, Error>(operation: {
            throw TestError.testError
        })
        do {
            _ = try await future.value
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? TestError, TestError.testError)
        }
    }
}
