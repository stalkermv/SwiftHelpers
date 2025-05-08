//
//  ContentlessTests.swift
//  SwiftHelpers
//
//  Created by Valeriy Malishevskyi on 02.05.2025.
//

import Testing
@testable import FoundationExtensions

struct ContentlessTests {
    @Test func contentless() {
        let testArray = [1, 2, 3, 4, 5]
        let expectedResult = false
        
        #expect(testArray.isContentless == expectedResult)
    }
    
    @Test func contentlessWithEmptyArray() {
        let testArray: [Int] = []
        let expectedResult = true
        
        #expect(testArray.isContentless == expectedResult)
    }
    
    @Test func contentlessWithNilArray() {
        let testArray: [Int]? = nil
        let expectedResult = true
        
        #expect(testArray.isContentless == expectedResult)
    }
    
    @Test func contentlessWithNilArrayElement() {
        let testArray: [Int?] = [nil, nil, nil]
        let expectedResult = true
        
        #expect(testArray.isContentless == expectedResult)
    }
        
    @Test func contentlessWithNilOptionalArrayElement() {
        let testArray: [Int?]? = [nil, nil, nil]
        let expectedResult = true
        
        #expect(testArray.isContentless == expectedResult)
    }
    
    @Test func contentlessWithMixedArray() {
        let testArray: [Int?] = [1, nil, 3]
        let expectedResult = false
        
        #expect(testArray.isContentless == expectedResult)
    }
    
    @Test func contentlessWithEmptyStringArray() {
        let testArray: [String] = ["", "", ""]
        let expectedResult = true
        
        #expect(testArray.isContentless == expectedResult)
    }
    
    @Test func contentlessWithMixedStringArray() {
        let testArray: [String] = ["", "Hello", ""]
        let expectedResult = false
        
        #expect(testArray.isContentless == expectedResult)
    }
    
    @Test func contentlessWithEmptyString() {
        let testString: String? = ""
        let expectedResult = true
        
        #expect(testString.isContentless == expectedResult)
    }
    
    @Test func contentlessString() {
        #expect("  ".isContentless == true)
        #expect("".isContentless == true)
        #expect(String?.none.isContentless == true)
        
        #expect("Hello".isContentless == false)
        #expect(String?.some("Hello").isContentless == false)
    }
}
