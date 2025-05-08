//
//  SequenceTests.swift
//  
//
//  Created by Valeriy Malishevskyi on 01.05.2023.
//

import Testing
@testable import FoundationExtensions

struct SequenceTests {
    struct Person: Equatable {
        let name: String
        let age: Int?
    }
    
    let people = [
        Person(name: "Alice", age: 30),
        Person(name: "Bob", age: 25),
        Person(name: "Charles", age: 35),
        Person(name: "David", age: nil)
    ]
    
    @Test func testUnique() {
        let input = [1, 2, 3, 1, 4, 3, 5, 2, 6]
        let expectedOutput = [1, 2, 3, 4, 5, 6]
        
        #expect(input.unique() == expectedOutput)
    }
    
    @Test func testUniqueEmpty() {
        let input: [Int] = []
        let expectedOutput: [Int] = []
        
        #expect(input.unique() == expectedOutput)
    }
    
    @Test func testUniqueBy() {
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
        
        #expect(input.unique(by: { $0.name }) == expectedOutput)
    }
}
