//
//  Array+UniquePropertyWrapper.swift
//  SwiftHelpers
//
//  Created by Valeriy Malishevskyi on 04.12.2025.
//

import Foundation

/// A property wrapper that automatically removes duplicate elements from an array.
///
/// The `Unique` property wrapper ensures that the wrapped array contains only unique elements
/// based on a specified key path. When a new value is set, duplicates are automatically removed
/// while preserving the order of the first occurrence of each unique element.
///
/// The wrapper supports three initialization modes:
/// - **Custom key path**: Specify a key path to determine uniqueness
/// - **Identifiable**: Automatically uses the element's `id` property for `Identifiable` types
/// - **Equatable**: Automatically uses the element itself for `Equatable` types
///
/// - Warning: If a type conforms to both `Identifiable` and `Equatable`, the `Identifiable`
///   initializer takes precedence. Uniqueness will be determined by the `id` property,
///   not by `Equatable` conformance. To use `Equatable` instead, explicitly specify
///   `@Unique(by: \.self)` or use a custom key path.
///
/// Usage Example:
/// ```
/// struct Person: Identifiable {
///     let id: Int
///     let name: String
/// }
///
/// class MyClass {
///     @Unique var people: [Person] = [
///         Person(id: 1, name: "Alice"),
///         Person(id: 2, name: "Bob"),
///         Person(id: 1, name: "Alice")  // Duplicate will be removed
///     ]
/// }
///
/// // Or with a custom key path:
/// class MyOtherClass {
///     @Unique(by: \.name) var peopleByName: [Person] = [...]
/// }
/// ```
@propertyWrapper
public struct Unique<Element, Key: Hashable> {
    private let keyPath: KeyPath<Element, Key>
    private var storage: [Element] = []

    /// Initializes the property wrapper with a custom key path for determining uniqueness.
    ///
    /// - Parameter keyPath: A key path to a property of the element that will be used to determine uniqueness.
    public init(by keyPath: KeyPath<Element, Key>) {
        self.keyPath = keyPath
    }
    
    /// Initializes the property wrapper with a custom key path and initial value.
    ///
    /// - Parameters:
    ///   - wrappedValue: The initial array value (duplicates will be removed).
    ///   - keyPath: A key path to a property of the element that will be used to determine uniqueness.
    public init(wrappedValue: [Element], by keyPath: KeyPath<Element, Key>) {
        self.keyPath = keyPath
        self.storage = Self.unique(wrappedValue, by: keyPath)
    }

    /// Initializes the property wrapper for `Identifiable` elements.
    ///
    /// This initializer automatically uses the element's `id` property to determine uniqueness.
    ///
    /// - Requires: `Element` must conform to `Identifiable` and `Element.ID` must be `Hashable`.
    ///   Note that `Identifiable` protocol requires `ID` to be `Hashable`, so this requirement
    ///   is automatically satisfied for all valid `Identifiable` types.
    /// - Note: If `Element` also conforms to `Equatable`, this initializer takes precedence
    ///   over the `Equatable` initializer. Uniqueness will be determined by `id`, not by
    ///   `Equatable` conformance.
    public init() where Element: Identifiable, Element.ID == Key {
        self.keyPath = \.id
    }
    
    /// Initializes the property wrapper for `Identifiable` elements with an initial value.
    ///
    /// - Parameter wrappedValue: The initial array value (duplicates will be removed).
    /// - Requires: `Element` must conform to `Identifiable` and `Element.ID` must be `Hashable`.
    ///   Note that `Identifiable` protocol requires `ID` to be `Hashable`, so this requirement
    ///   is automatically satisfied for all valid `Identifiable` types.
    /// - Note: If `Element` also conforms to `Equatable`, this initializer takes precedence
    ///   over the `Equatable` initializer. Uniqueness will be determined by `id`, not by
    ///   `Equatable` conformance.
    public init(wrappedValue: [Element]) where Element: Identifiable, Element.ID == Key {
        self.keyPath = \.id
        self.storage = Self.unique(wrappedValue, by: keyPath)
    }

    /// Initializes the property wrapper for `Equatable` elements.
    ///
    /// This initializer automatically uses the element itself to determine uniqueness.
    ///
    /// - Requires: `Element` must conform to both `Equatable` and `Hashable`.
    /// - Note: This initializer is only used when `Element` does not conform to `Identifiable`.
    ///   If `Element` conforms to both `Identifiable` and `Equatable`, the `Identifiable`
    ///   initializer takes precedence.
    public init() where Element: Equatable, Element == Key {
        self.keyPath = \.self
    }
    
    /// Initializes the property wrapper for `Equatable` elements with an initial value.
    ///
    /// - Parameter wrappedValue: The initial array value (duplicates will be removed).
    /// - Requires: `Element` must conform to both `Equatable` and `Hashable`.
    /// - Note: This initializer is only used when `Element` does not conform to `Identifiable`.
    ///   If `Element` conforms to both `Identifiable` and `Equatable`, the `Identifiable`
    ///   initializer takes precedence.
    public init(wrappedValue: [Element]) where Element: Equatable, Element == Key {
        self.keyPath = \.self
        self.storage = Self.unique(wrappedValue, by: keyPath)
    }

    /// The wrapped array value with duplicate elements automatically removed.
    ///
    /// When setting a new value, duplicates are removed based on the configured key path,
    /// preserving the order of the first occurrence of each unique element.
    public var wrappedValue: [Element] {
        get { storage }
        set { storage = Self.unique(newValue, by: keyPath) }
    }
    
    // MARK: - Deduplication logic
    
    /// Removes duplicate elements from an array based on a key path.
    ///
    /// This method preserves the order of the first occurrence of each unique element
    /// by reusing the existing `unique(by:)` extension method.
    ///
    /// - Parameters:
    ///   - array: The array to deduplicate.
    ///   - keyPath: The key path used to determine uniqueness.
    /// - Returns: A new array containing only unique elements in the order they first appeared.
    private static func unique(
        _ array: [Element],
        by keyPath: KeyPath<Element, Key>
    ) -> [Element] {
        // Reuse the existing unique(by:) extension method with a closure wrapper
        return array.unique(by: { $0[keyPath: keyPath] })
    }
}
