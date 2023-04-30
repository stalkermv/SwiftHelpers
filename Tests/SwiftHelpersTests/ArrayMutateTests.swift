//
//  ArrayMutateTests.swift
//  
//
//  Created by Valeriy Malishevskyi on 01.05.2023.
//

import XCTest
import SwiftHelpers

final class ArrayMutateTests: XCTestCase {
    let testArray = [1, 2, 3, 4, 5]

    func testMutate() {
        let expectedResult = [2, 4, 6, 8, 10]
        let mutatedArray = testArray.mutate { element in
            element *= 2
        }
        
        XCTAssertEqual(mutatedArray, expectedResult)
    }
}
