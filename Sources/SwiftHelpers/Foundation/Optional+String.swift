//
//  File.swift
//  
//
//  Created by Valeriy Malishevskyi on 01.05.2023.
//

import Foundation

extension Optional where Wrapped == String {
    /// The property returns true if the wrapped string is nil, empty, or contains only whitespace characters, and false otherwise.
    ///
    /// Example of how to use the isContentless property:
    ///  ```
    /// let stringWithSpaces: String? = "   "
    /// let emptyString: String? = ""
    /// let nilString: String? = nil
    /// let stringWithContent: String? = "Hello, World!"
    /// print(stringWithSpaces.isContentless) // Prints "true"
    /// print(emptyString.isContentless)      // Prints "true"
    /// print(nilString.isContentless)        // Prints "true"
    /// print(stringWithContent.isContentless)// Prints "false"
    /// ```
    var isContentless: Bool {
        switch self {
        case .none:
            return true
        case .some(let value):
            return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
}
