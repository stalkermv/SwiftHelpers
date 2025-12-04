//
//  ArrayUniquePropertyWrapperTests.swift
//  
//
//  Created by Valeriy Malishevskyi on 04.12.2025.
//

import Testing
@testable import FoundationExtensions

struct ArrayUniquePropertyWrapperTests {
    
    // MARK: - Test Models
    
    struct Person: Identifiable, Equatable {
        let id: Int
        let name: String
        let age: Int
    }
    
    struct Product: Equatable {
        let code: String
        let name: String
        let price: Double
    }
    
    // MARK: - Identifiable Tests
    
    @Test func testUniqueByIdentifiable() {
        struct TestClass {
            @Unique var items: [Person] = []
        }
        
        var testClass = TestClass()
        testClass.items = [
            Person(id: 1, name: "Alice", age: 30),
            Person(id: 2, name: "Bob", age: 25),
            Person(id: 1, name: "Alice Duplicate", age: 35),
            Person(id: 3, name: "Charles", age: 40),
            Person(id: 2, name: "Bob Duplicate", age: 45)
        ]
        
        let expected = [
            Person(id: 1, name: "Alice", age: 30),
            Person(id: 2, name: "Bob", age: 25),
            Person(id: 3, name: "Charles", age: 40)
        ]
        
        #expect(testClass.items == expected)
        #expect(testClass.items.count == 3)
    }
    
    @Test func testUniqueByIdentifiableEmptyArray() {
        struct TestClass {
            @Unique var items: [Person] = []
        }
        
        var testClass = TestClass()
        testClass.items = []
        
        #expect(testClass.items.isEmpty)
    }
    
    @Test func testUniqueByIdentifiableNoDuplicates() {
        struct TestClass {
            @Unique var items: [Person] = []
        }
        
        var testClass = TestClass()
        testClass.items = [
            Person(id: 1, name: "Alice", age: 30),
            Person(id: 2, name: "Bob", age: 25),
            Person(id: 3, name: "Charles", age: 40)
        ]
        
        #expect(testClass.items.count == 3)
    }
    
    @Test func testIdentifiableTakesPrecedenceOverEquatable() {
        // This test demonstrates that when a type conforms to both Identifiable and Equatable,
        // the Identifiable initializer takes precedence, so uniqueness is determined by id,
        // not by Equatable conformance.
        struct TestClass {
            @Unique var items: [Person] = []
        }
        
        var testClass = TestClass()
        // Create two Person objects with same name and age (equal by Equatable),
        // but different ids - they should NOT be considered duplicates
        testClass.items = [
            Person(id: 1, name: "Alice", age: 30),
            Person(id: 2, name: "Alice", age: 30), // Same name and age, different id
            Person(id: 1, name: "Bob", age: 25)    // Same id as first, different name/age
        ]
        
        // Should have 2 items: one with id=1, one with id=2
        // The second Person(id: 1, ...) should be removed as duplicate by id
        #expect(testClass.items.count == 2)
        #expect(testClass.items[0].id == 1)
        #expect(testClass.items[1].id == 2)
        // Verify that Equatable equality was ignored - we have two "Alice" with age 30
        #expect(testClass.items[0].name == "Alice")
        #expect(testClass.items[0].age == 30)
        #expect(testClass.items[1].name == "Alice")
        #expect(testClass.items[1].age == 30)
    }
    
    // MARK: - Custom KeyPath Tests
    
    @Test func testUniqueByCustomKeyPath() {
        struct TestClass {
            @Unique(by: \.code) var products: [Product] = []
        }
        
        var testClass = TestClass()
        testClass.products = [
            Product(code: "A001", name: "Product A", price: 10.0),
            Product(code: "B002", name: "Product B", price: 20.0),
            Product(code: "A001", name: "Product A Duplicate", price: 15.0),
            Product(code: "C003", name: "Product C", price: 30.0),
            Product(code: "B002", name: "Product B Duplicate", price: 25.0)
        ]
        
        let expected = [
            Product(code: "A001", name: "Product A", price: 10.0),
            Product(code: "B002", name: "Product B", price: 20.0),
            Product(code: "C003", name: "Product C", price: 30.0)
        ]
        
        #expect(testClass.products == expected)
        #expect(testClass.products.count == 3)
    }
    
    @Test func testUniqueByCustomKeyPathName() {
        struct TestClass {
            @Unique(by: \.name) var products: [Product] = []
        }
        
        var testClass = TestClass()
        testClass.products = [
            Product(code: "A001", name: "Product A", price: 10.0),
            Product(code: "A002", name: "Product B", price: 20.0),
            Product(code: "A003", name: "Product A", price: 15.0), // Same name, different code
            Product(code: "A004", name: "Product C", price: 30.0)
        ]
        
        #expect(testClass.products.count == 3)
        #expect(testClass.products[0].name == "Product A")
        #expect(testClass.products[1].name == "Product B")
        #expect(testClass.products[2].name == "Product C")
    }
    
    // MARK: - Equatable Tests
    
    @Test func testUniqueByEquatable() {
        struct TestClass {
            @Unique var numbers: [Int] = []
        }
        
        var testClass = TestClass()
        testClass.numbers = [1, 2, 3, 1, 4, 3, 5, 2, 6]
        
        let expected = [1, 2, 3, 4, 5, 6]
        
        #expect(testClass.numbers == expected)
        #expect(testClass.numbers.count == 6)
    }
    
    @Test func testUniqueByEquatableStrings() {
        struct TestClass {
            @Unique var strings: [String] = []
        }
        
        var testClass = TestClass()
        testClass.strings = ["apple", "banana", "apple", "cherry", "banana", "date"]
        
        let expected = ["apple", "banana", "cherry", "date"]
        
        #expect(testClass.strings == expected)
        #expect(testClass.strings.count == 4)
    }
    
    @Test func testUniqueByEquatableEmpty() {
        struct TestClass {
            @Unique var numbers: [Int] = []
        }
        
        var testClass = TestClass()
        testClass.numbers = []
        
        #expect(testClass.numbers.isEmpty)
    }
    
    // MARK: - Order Preservation Tests
    
    @Test func testOrderPreservation() {
        struct TestClass {
            @Unique var items: [Person] = []
        }
        
        var testClass = TestClass()
        testClass.items = [
            Person(id: 3, name: "Third", age: 30),
            Person(id: 1, name: "First", age: 25),
            Person(id: 2, name: "Second", age: 35),
            Person(id: 3, name: "Third Again", age: 40),
            Person(id: 1, name: "First Again", age: 45)
        ]
        
        // Should preserve order of first occurrence
        #expect(testClass.items[0].id == 3)
        #expect(testClass.items[1].id == 1)
        #expect(testClass.items[2].id == 2)
        #expect(testClass.items[0].name == "Third")
        #expect(testClass.items[1].name == "First")
        #expect(testClass.items[2].name == "Second")
    }
    
    // MARK: - Multiple Updates Tests
    
    @Test func testMultipleUpdates() {
        struct TestClass {
            @Unique var items: [Person] = []
        }
        
        var testClass = TestClass()
        
        // First update
        testClass.items = [
            Person(id: 1, name: "Alice", age: 30),
            Person(id: 2, name: "Bob", age: 25)
        ]
        
        #expect(testClass.items.count == 2)
        
        // Second update with duplicates
        testClass.items = [
            Person(id: 1, name: "Alice Updated", age: 35),
            Person(id: 2, name: "Bob", age: 25),
            Person(id: 3, name: "Charles", age: 40),
            Person(id: 1, name: "Alice Again", age: 45)
        ]
        
        #expect(testClass.items.count == 3)
    }
    
    // MARK: - Complex Scenarios
    
    @Test func testAllDuplicates() {
        struct TestClass {
            @Unique var items: [Person] = []
        }
        
        var testClass = TestClass()
        testClass.items = [
            Person(id: 1, name: "Same", age: 30),
            Person(id: 1, name: "Same", age: 25),
            Person(id: 1, name: "Same", age: 35)
        ]
        
        #expect(testClass.items.count == 1)
        #expect(testClass.items[0].id == 1)
    }
    
    @Test func testLargeArray() {
        struct TestClass {
            @Unique var numbers: [Int] = []
        }
        
        var testClass = TestClass()
        var input: [Int] = []
        for i in 0..<1000 {
            input.append(i % 100) // Creates duplicates
        }
        
        testClass.numbers = input
        
        #expect(testClass.numbers.count == 100)
        #expect(testClass.numbers.sorted() == Array(0..<100))
    }
}
