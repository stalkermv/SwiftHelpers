//
//  OptionalAssign.swift
//  SwiftHelpers
//
//  Created by Valeriy Malishevskyi on 13.07.2024.
//

/// A conditional assignment operator for optional-aware value assignment.
///
/// The `?=` operator assigns a value to the left-hand side only if the right-hand side is non-`nil`.
/// It is particularly useful when updating values only when new data is present, without overwriting existing values with `nil`.
///
/// This operator has `AssignmentPrecedence`, allowing it to behave like a standard assignment in compound expressions.
infix operator ?= : AssignmentPrecedence

/// Conditionally assigns a non-`nil` value to an optional target.
///
/// Assigns `rhs` to `lhs` only if `rhs` is not `nil`.
///
/// ```swift
/// var name: String? = "Alice"
/// let newName: String? = "Bob"
/// name ?= newName // name is now "Bob"
///
/// let emptyName: String? = nil
/// name ?= emptyName // name remains "Bob"
/// ```
///
/// - Parameters:
///   - lhs: The optional variable to be updated.
///   - rhs: The optional value to assign if non-`nil`.
public func ?=<T>(_ lhs: inout T?, _ rhs: T?) {
    if let rhs {
        lhs = rhs
    }
}

/// Conditionally assigns a non-`nil` value to a non-optional target.
///
/// Assigns `rhs` to `lhs` only if `rhs` is not `nil`.
///
/// ```swift
/// var count = 5
/// let newCount: Int? = 10
/// count ?= newCount // count is now 10
///
/// let noUpdate: Int? = nil
/// count ?= noUpdate // count remains 10
/// ```
///
/// - Parameters:
///   - lhs: The non-optional variable to be updated.
///   - rhs: The optional value to assign if non-`nil`.
public func ?=<T>(_ lhs: inout T, _ rhs: T?) {
    if let rhs {
        lhs = rhs
    }
}
