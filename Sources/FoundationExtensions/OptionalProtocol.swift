//
//  OptionalProtocol.swift
//
//  Created by Valeriy Malishevskyi on 21.08.2023.
//

import Foundation

/// A protocol that abstracts the concept of an optional value.
///
/// `OptionalProtocol` provides a uniform interface for working with types that
/// can represent the presence or absence of a value. It includes a property to
/// check whether a value is absent (`isNone`) and requires conformance to
/// `ExpressibleByNilLiteral` to allow initialization from `nil`.
public protocol OptionalProtocol: ExpressibleByNilLiteral {
    
    /// The type of the value wrapped inside the optional.
    associatedtype Wrapped
    
    /// A Boolean value indicating whether the optional is `.none`.
    ///
    /// Use this property to determine if the optional does not contain a value.
    ///
    /// ```swift
    /// let value: Int? = nil
    /// print(value.isNone) // true
    /// ```
    var isNone: Bool { get }
    
    /// The wrapped value, or `nil` if the optional is `none`.
    var wrappedValue: Wrapped { get throws }
}

extension Optional: OptionalProtocol {
    /// A Boolean value indicating whether the optional is `.none`.
    ///
    /// Returns `true` if the optional does not contain a value, otherwise `false`.
    public var isNone: Bool {
        switch self {
        case .none:
            return true
        case .some:
            return false
        }
    }
    
    /// The unwrapped value of the optional.
    ///
    /// Throws an `OptionalUnwrapError.emptyValue` error if the optional is `.none`.
    ///
    /// Use this property to safely extract the value from an optional. It provides
    /// a throwing getter, allowing you to handle the absence of a value explicitly.
    ///
    /// ```swift
    /// let value: Int? = 10
    /// do {
    ///     let unwrapped = try value.wrappedValue
    ///     print(unwrapped) // 10
    /// } catch {
    ///     print(error)
    /// }
    /// ```
    ///
    /// - Throws: `OptionalUnwrapError.emptyValue` if the optional is `.none`.
    @available(*, deprecated, message: "Use unwrapped() instead")
    public var wrappedValue: Wrapped {
        get throws {
            switch self {
            case .none:
                throw OptionalUnwrapError.emptyValue()
            case .some(let value):
                return value
            }
        }
    }
}
