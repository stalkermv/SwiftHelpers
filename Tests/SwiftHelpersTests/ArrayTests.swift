//
//  ArrayTests.swift
//  
//
//  Created by Valeriy Malishevskyi on 01.05.2023.
//

import XCTest
@testable import SwiftHelpers

final class ArraySortingTests: XCTestCase {
    
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
    
    func testSortByNameAscending() {
        let sortedPeople = people.sorted(keyPath: \.name)
        let expected = [
            Person(name: "Alice", age: 30),
            Person(name: "Bob", age: 25),
            Person(name: "Charles", age: 35),
            Person(name: "David", age: nil)
        ]
        XCTAssertEqual(sortedPeople, expected)
    }
    
    func testSortByNameDescending() {
        let sortedPeople = people.sorted(keyPath: \.name, ascending: false)
        let expected = [
            Person(name: "David", age: nil),
            Person(name: "Charles", age: 35),
            Person(name: "Bob", age: 25),
            Person(name: "Alice", age: 30)
        ]
        XCTAssertEqual(sortedPeople, expected)
    }
    
    func testSortByAgeAscending() {
        let sortedPeople = people.sorted(keyPath: \.age)
        let expected = [
            Person(name: "Bob", age: 25),
            Person(name: "Alice", age: 30),
            Person(name: "Charles", age: 35),
            Person(name: "David", age: nil)
        ]
        XCTAssertEqual(sortedPeople, expected)
    }
    
    func testSortByAgeDescending() {
        let sortedPeople = people.sorted(keyPath: \.age, ascending: false)
        let expected = [
            Person(name: "Charles", age: 35),
            Person(name: "Alice", age: 30),
            Person(name: "Bob", age: 25),
            Person(name: "David", age: nil)
        ]
        XCTAssertEqual(sortedPeople, expected)
    }
}
