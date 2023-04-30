//
//  SafeIndexTests.swift
//  
//
//  Created by Valeriy Malishevskyi on 01.05.2023.
//

import XCTest
import SwiftHelpers

class SafeIndexTests: XCTestCase {
    let testArray = [1, 2, 3, 4, 5]

    func testSafeIndex() {
        XCTAssertEqual(testArray[safeIndex: 0], 1)
        XCTAssertEqual(testArray[safeIndex: 1], 2)
        XCTAssertEqual(testArray[safeIndex: 2], 3)
        XCTAssertEqual(testArray[safeIndex: 3], 4)
        XCTAssertEqual(testArray[safeIndex: 4], 5)
        
        XCTAssertNil(testArray[safeIndex: -1])
        XCTAssertNil(testArray[safeIndex: 5])
        XCTAssertNil(testArray[safeIndex: 10])
    }
}
