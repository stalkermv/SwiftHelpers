//
//  FlattenExtensions.swift
//  SwiftHelpers
//
//  Created by Valeriy Malishevskyi on 07.05.2025.
//

import FoundationExtensions

extension Optional {
    /// Flattens an array of optionals contained inside an optional, removing any `nil` values.
    ///
    /// This method is useful for working with nested optional arrays, especially when
    /// you want to retrieve the non-`nil` values.
    ///
    /// - Returns: An array of non-optional elements, with any `nil` values removed.
    ///
    /// ### Example:
    /// ```
    /// let optionalArray: [Int?]? = [1, nil, 3]
    /// let flattened: [Int] = optionalArray.flatten()
    /// // flattened == [1, 3]
    /// ```
    public func flatten<T>() -> Array<T> where Wrapped == Array<T?> {
        self?.compactMap { $0 } ?? []
    }
}

extension Array where Element: OptionalProtocol {
    /// Flattens an array of optional-like elements, removing any `nil` values.
    ///
    /// This method uses the `OptionalProtocol` to access the wrapped values of
    /// the elements and removes any `nil` values from the result.
    ///
    /// - Returns: An array of non-optional elements, with any `nil` values removed.
    ///
    /// ### Example:
    /// ```
    /// let array: [Int?] = [1, nil, 3]
    /// let flattened: [Int] = array.flatten()
    /// // flattened == [1, 3]
    /// ```
    public func flatten() -> [Element.Wrapped] {
        compactMap { try? $0.wrappedValue }
    }
}
