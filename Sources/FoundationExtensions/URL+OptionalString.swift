//
//  URL+OptionalString.swift
//  
//
//  Created by Valeriy Malishevskyi on 28.12.2021.
//

import Foundation

public extension URL {
    /// Creates a `URL` instance from an optional string.
    ///
    /// This initializer attempts to initialize a `URL` from the given optional string.
    /// If the string is `nil`, the initializer returns `nil`. If the string is non-`nil`
    /// but not a valid URL, the initializer also returns `nil` as per `URL(string:)` behavior.
    ///
    /// This is a convenience initializer that helps avoid unwrapping optional strings manually
    /// before creating a `URL`.
    ///
    /// ```swift
    /// let validURL = URL(string: "https://www.apple.com") // URL
    /// let optionalURL = URL(string: nil) // nil
    /// ```
    ///
    /// - Parameter string: An optional string from which to create a URL.
    init?(string: String?) {
        guard let string = string else {
            return nil
        }

        self.init(string: string)
    }
}
