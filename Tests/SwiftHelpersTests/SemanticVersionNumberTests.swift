//
//  SemanticVersionNumberTests.swift
//  SwiftHelpers
//
//  Created by Valeriy Malishevskyi on 03.05.2025.
//

import Testing
@testable import SwiftHelpers

struct SemanticVersionNumberTests {
    @Test func initializationFromString() {
        let version = SemanticVersionNumber(version: "1.2.3")
        #expect(version != nil)
        #expect(version?.major == 1)
        #expect(version?.minor == 2)
        #expect(version?.patch == 3)
    }
    
    @Test func initializationFromInvalidString() {
        let version = SemanticVersionNumber(version: "1.2")
        #expect(version == nil)
        
        let version2 = SemanticVersionNumber(version: "1.2.3.4")
        #expect(version2 == nil)
        
        let version3 = SemanticVersionNumber(version: "a.b.c")
        #expect(version3 == nil)
    }
    
    @Test func initializationFromComponents() {
        let version = SemanticVersionNumber(major: 1, minor: 2, patch: 3)
        #expect(version.major == 1)
        #expect(version.minor == 2)
        #expect(version.patch == 3)
    }
    
    @Test func initializationFromStringComponents() {
        let version = SemanticVersionNumber(major: "1", minor: "2", patch: "3")
        #expect(version != nil)
        #expect(version?.major == 1)
        #expect(version?.minor == 2)
        #expect(version?.patch == 3)
    }
    
    @Test func initializationFromInvalidStringComponents() {
        let version = SemanticVersionNumber(major: "a", minor: "2", patch: "3")
        #expect(version == nil)
        
        let version2 = SemanticVersionNumber(major: "1", minor: "b", patch: "3")
        #expect(version2 == nil)
        
        let version3 = SemanticVersionNumber(major: "1", minor: "2", patch: "c")
        #expect(version3 == nil)
    }
    
    @Test func comparison() {
        let v1 = SemanticVersionNumber(major: 1, minor: 2, patch: 3)
        let v2 = SemanticVersionNumber(major: 1, minor: 2, patch: 4)
        let v3 = SemanticVersionNumber(major: 1, minor: 3, patch: 0)
        let v4 = SemanticVersionNumber(major: 2, minor: 0, patch: 0)
        
        #expect(v1 < v2)
        #expect(v2 < v3)
        #expect(v3 < v4)
        #expect(v1 < v4)
    }
    
    @Test func equality() {
        let v1 = SemanticVersionNumber(major: 1, minor: 2, patch: 3)
        let v2 = SemanticVersionNumber(major: 1, minor: 2, patch: 3)
        let v3 = SemanticVersionNumber(major: 1, minor: 2, patch: 4)
        
        #expect(v1 == v2)
        #expect(v1 != v3)
    }
    
    @Test func description() {
        let version = SemanticVersionNumber(major: 1, minor: 2, patch: 3)
        #expect(version.description == "1.2.3")
    }
}

