//
//  OptionalAssign.swift
//  SwiftHelpers
//
//  Created by Valeriy Malishevskyi on 02.05.2025.
//

import Testing
@testable import SwiftHelpers

struct OptionalAssignTests {
    @Test func optionalAssign() {
        var optionalValue: Int? = nil
        let newValue: Int? = 42
        
        optionalValue ?= newValue
        
        #expect(optionalValue == 42)
    }
    
    @Test func optionalAssignWithNil() {
        var optionalValue: Int? = nil
        let newValue: Int? = nil
        
        optionalValue ?= newValue
        
        #expect(optionalValue == nil)
    }
    
    @Test func optionalAssignWithNonNil() {
        var optionalValue: Int? = 10
        let newValue: Int? = 42
        
        optionalValue ?= newValue
        
        #expect(optionalValue == 42)
    }
    
    @Test func optionalAssignWithNonNilAndNil() {
        var optionalValue: Int? = 10
        let newValue: Int? = nil
        
        optionalValue ?= newValue
        
        #expect(optionalValue == 10)
    }
    
    struct Person {
        var name: String?
        var age: Int?
        var address: String?
        var phone: String?
    }
    
    @Test func optionalAssignBatch() {
        var person = Person(
            name: "Jane Doe",
            age: nil,
            address: "123 Main St",
            phone: nil
        )
        
        let updates: Person = .init(
            name: "John Doe",
            age: 30,
            address: nil,
            phone: "123-456-7890"
        )
        
        person.name ?= updates.name
        person.age ?= updates.age
        person.address ?= updates.address
        person.phone ?= updates.phone
        
        #expect(person.name == "John Doe")
        #expect(person.age == 30)
        #expect(person.address == "123 Main St")
        #expect(person.phone == "123-456-7890")
    }
}
