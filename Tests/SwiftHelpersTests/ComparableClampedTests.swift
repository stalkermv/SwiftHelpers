//
//  ComparableClampedTests.swift
//  
//
//  Created by Valeriy Malishevskyi on 01.05.2023.
//

import XCTest
import SwiftHelpers

final class ComparableClampedTests: XCTestCase {
    
    func testClamped() {
        XCTAssertEqual(5.clamped(to: 1...10), 5)
        XCTAssertEqual(0.clamped(to: 1...10), 1)
        XCTAssertEqual(11.clamped(to: 1...10), 10)
        
        XCTAssertEqual(3.5.clamped(to: 2.0...4.0), 3.5)
        XCTAssertEqual(1.5.clamped(to: 2.0...4.0), 2.0)
        XCTAssertEqual(4.5.clamped(to: 2.0...4.0), 4.0)
    }
}
