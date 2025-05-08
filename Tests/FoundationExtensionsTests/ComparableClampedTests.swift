//
//  ComparableClampedTests.swift
//  
//
//  Created by Valeriy Malishevskyi on 01.05.2023.
//

import Testing
@testable import FoundationExtensions

struct ComparableClampedTests {
    @Test func clamped() {
        #expect(5.clamped(to: 1...10) == 5)
        #expect(0.clamped(to: 1...10) == 1)
        #expect(11.clamped(to: 1...10) == 10)
        
        #expect(3.5.clamped(to: 2.0...4.0) == 3.5)
        #expect(1.5.clamped(to: 2.0...4.0) == 2.0)
        #expect(4.5.clamped(to: 2.0...4.0) == 4.0)
    }
}
