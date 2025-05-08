//
//  ArrayMutateTests.swift
//  
//
//  Created by Valeriy Malishevskyi on 01.05.2023.
//

import Testing
@testable import FoundationExtensions

@Test func mutateArray() async throws {
    let testArray = [1, 2, 3, 4, 5]
    let expectedResult = [2, 4, 6, 8, 10]
    let mutatedArray = testArray.mutate { element in
        element *= 2
    }
    
    #expect(mutatedArray == expectedResult)
}
