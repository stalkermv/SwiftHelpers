//
//  Optional+Unwrap.swift
//  
//
//  Created by Valeriy Malishevskyi on 27.01.2022.
//

import Foundation

public extension Optional {
    /// Unwraps an optional value, throwing the specified error if the value is `nil`.
    ///
    /// This function attempts to unwrap the optional value. If the value is `nil`, it throws the provided error.
    /// Otherwise, it returns the unwrapped value.
    ///
    /// - Parameter error: The error to throw if the optional value is `nil`.
    /// - Throws: The specified error if the optional value is `nil`.
    /// - Returns: The unwrapped value if the optional value is not `nil`.
    func unwrap(or error: Error) throws -> Wrapped {
        guard let value = self else {
            throw error
        }
        return value
    }
}
