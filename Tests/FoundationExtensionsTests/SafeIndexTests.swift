//
//  SafeIndexTests.swift
//  
//
//  Created by Valeriy Malishevskyi on 01.05.2023.
//

import Testing
@testable import FoundationExtensions

struct SafeIndexTests {
    let testArray = [1, 2, 3, 4, 5]
    
    @Test func safeIndex() {
        #expect(testArray[safeIndex: 0] == 1)
        #expect(testArray[safeIndex: 1] == 2)
        #expect(testArray[safeIndex: 2] == 3)
        #expect(testArray[safeIndex: 3] == 4)
        #expect(testArray[safeIndex: 4] == 5)
        
        #expect(testArray[safeIndex: -1] == nil)
        #expect(testArray[safeIndex: 5] == nil)
        #expect(testArray[safeIndex: 10] == nil)
    }
}
