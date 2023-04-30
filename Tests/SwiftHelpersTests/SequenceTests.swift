//
//  SequenceTests.swift
//  
//
//  Created by Valeriy Malishevskyi on 01.05.2023.
//

import XCTest
import SwiftHelpers

final class SequenceTests: XCTestCase {
    
    struct Person: Equatable {
        let name: String
        let age: Int
    }
    
    func testUnique() {
        let input = [1, 2, 3, 1, 4, 3, 5, 2, 6]
        let expectedOutput = [1, 2, 3, 4, 5, 6]
        
        XCTAssertEqual(input.unique(), expectedOutput)
    }
    
    func testUniqueEmpty() {
        let input: [Int] = []
        let expectedOutput: [Int] = []
        
        XCTAssertEqual(input.unique(), expectedOutput)
    }
    
    func testUniqueBy() {
        let input = [
            Person(name: "Alice", age: 30),
            Person(name: "Bob", age: 25),
            Person(name: "Alice", age: 40),
            Person(name: "Charles", age: 35)
        ]
        
        let expectedOutput = [
            Person(name: "Alice", age: 30),
            Person(name: "Bob", age: 25),
            Person(name: "Charles", age: 35)
        ]
        
        XCTAssertEqual(input.unique(by: { $0.name }), expectedOutput)
    }
    
    func testUniqueByEmpty() {
        let input: [Person] = []
        let expectedOutput: [Person] = []
        
        XCTAssertEqual(input.unique(by: { $0.name }), expectedOutput)
    }
}
