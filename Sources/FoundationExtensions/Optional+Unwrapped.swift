//
//  Optional+Unwrapped.swift
//  SwiftUIHelpers
//
//  Created by Valeriy Malishevskyi on 14.07.2024.
//

import Foundation

extension Optional {
    /// Unwrap the optional or throw an error
    /// - Parameter error: The error to throw if the optional is `nil`
    /// - Returns: The unwrapped value
    public func unwrapped(or error: Error = OptionalUnwrapError.emptyValue) throws -> Wrapped {
        switch self {
        case .some(let value):
            return value
        case .none:
            print(error, "\(type(of: self))")
            throw error
        }
    }
    
    public func unwrapped(_ message: String) throws -> Wrapped {
        switch self {
        case .some(let value):
            return value
        case .none:
            print(message, "\(type(of: self))")
            throw OptionalUnwrapError.message(message)
        }
    }
    
    public enum OptionalUnwrapError: LocalizedError {
        case emptyValue
        case message(String)
        
        public var recoverySuggestion: String? {
            switch self {
            case .emptyValue:
                return "Check the value before unwrapping"
            case .message(let message):
                return message
            }
        }
        
        public var errorDescription: String? {
            switch self {
            case .emptyValue:
                return "Received an unexpected empty value"
            case .message(let message):
                return message
            }
        }
    }
}

