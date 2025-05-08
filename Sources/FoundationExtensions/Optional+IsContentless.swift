//
//  Optional+IsContentless.swift
//  SwiftHelpers
//
//  Created by Valeriy Malishevskyi on 17.04.2025.
//

import Foundation

/// A protocol for types that can be meaningfully described as "empty".
///
/// Conforming types define what it means for their instances to be considered empty,
/// typically exposing whether they contain no significant data.
public protocol Emptyable {
    
    /// A Boolean value indicating whether the instance is empty.
    ///
    /// Should return `true` if the instance holds no meaningful data.
    var isEmpty: Bool { get }
}

/// A protocol for types that can be evaluated for contentlessness — i.e., no meaningful data.
///
/// `Contentless` is a generalization of `Emptyable` for use cases involving
/// optionals, collections, or nested structures where content may be absent or trivial.
public protocol Contentless {
    
    /// A Boolean value indicating whether the value is considered contentless.
    ///
    /// Returns `true` if the instance lacks meaningful or usable data.
    var isContentless: Bool { get }
}

// MARK: - String

extension String: Emptyable, Contentless {

    /// Returns `true` if the string, after trimming whitespace and newlines, is empty.
    ///
    /// This helps identify strings that may technically contain characters but are
    /// visually or semantically empty (e.g., `"   \n"`).
    public var isContentless: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Optional + Contentless

extension Optional: Contentless {

    /// Returns `true` if the optional is `nil`, or if it wraps a `Contentless` value that is itself contentless.
    ///
    /// This allows evaluating deeply nested or optional structures in a uniform way.
    ///
    /// ```swift
    /// let text: String? = "   "
    /// print(text.isContentless) // true
    ///
    /// let nonEmpty: Int? = 42
    /// print(nonEmpty.isContentless) // false
    /// ```
    public var isContentless: Bool {
        switch self {
        case .none:
            return true
        case .some(let value as Contentless):
            return value.isContentless
        case .some:
            return false
        }
    }
}

// MARK: - Array + Contentless

extension Array: Contentless {

    /// Returns `true` if the array is empty or all its non-`nil` elements are contentless.
    ///
    /// The method filters out `nil` values by checking for `OptionalProtocol` conformance and
    /// evaluating whether remaining non-`nil` elements conform to `Contentless`.
    ///
    /// ```swift
    /// let array: [String?] = [nil, "   "]
    /// print(array.isContentless) // true
    ///
    /// let mixed: [Any?] = [nil, "hello"]
    /// print(mixed.isContentless) // false
    /// ```
    public var isContentless: Bool {
        if self.isEmpty {
            return true
        }

        let nonNilElements: [Any] = self.compactMap {
            if let optional = $0 as? OptionalProtocol, optional.isNone {
                return nil
            }
            return $0
        }

        if nonNilElements.isEmpty {
            return true
        }

        return nonNilElements.allSatisfy {
            if let contentless = $0 as? Contentless {
                return contentless.isContentless
            }
            return false
        }
    }
}
