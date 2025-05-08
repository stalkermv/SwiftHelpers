//
//  ArrayTests.swift
//  
//
//  Created by Valeriy Malishevskyi on 01.05.2023.
//

import Testing
@testable import FoundationExtensions

struct ArraySortingTests {
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
    
    @Test func sortByNameAscending() {
        let sortedPeople = people.sorted(keyPath: \.name)
        let expected = [
            Person(name: "Alice", age: 30),
            Person(name: "Bob", age: 25),
            Person(name: "Charles", age: 35),
            Person(name: "David", age: nil)
        ]
        #expect(sortedPeople == expected)
    }
    
    @Test func sortByNameDescending() {
        let sortedPeople = people.sorted(keyPath: \.name, ascending: false)
        let expected = [
            Person(name: "David", age: nil),
            Person(name: "Charles", age: 35),
            Person(name: "Bob", age: 25),
            Person(name: "Alice", age: 30)
        ]
        #expect(sortedPeople == expected)
    }
    
    @Test func sortByAgeAscending() {
        let sortedPeople = people.sorted(keyPath: \.age)
        let expected = [
            Person(name: "Bob", age: 25),
            Person(name: "Alice", age: 30),
            Person(name: "Charles", age: 35),
            Person(name: "David", age: nil)
        ]
        #expect(sortedPeople == expected)
    }
    
    @Test func sortByAgeDescending() {
        let sortedPeople = people.sorted(keyPath: \.age, ascending: false)
        let expected = [
            Person(name: "Charles", age: 35),
            Person(name: "Alice", age: 30),
            Person(name: "Bob", age: 25),
            Person(name: "David", age: nil)
        ]
        #expect(sortedPeople == expected)
    }
    
    @Test func firstIndexOf() {
        let input = [1, 2, 3, 4, 5]
        let expectedOutput = 2
        
        #expect(input.firstIndex(of: 3) == expectedOutput)
    }
    
    @Test func appending() {
        let input = [1, 2, 3]
        let elementToAppend = 4
        let expectedOutput = [1, 2, 3, 4]
        
        #expect(input.appending(elementToAppend) == expectedOutput)
    }
}
