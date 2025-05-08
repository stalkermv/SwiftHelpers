//
//  EquatableNoop.swift
//  SwiftHelpers
//
//  Created by Valeriy Malishevskyi on 13.09.2024.
//

import Foundation

@propertyWrapper
public struct EquatableNoop<Value: Sendable>: Equatable, Sendable {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public static func == (lhs: EquatableNoop, rhs: EquatableNoop) -> Bool {
        true
    }
}

extension EquatableNoop: Decodable where Value: Decodable {
    public init(from decoder: Decoder) throws {
        self.init(wrappedValue: try Value(from: decoder))
    }
}

extension EquatableNoop: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}
