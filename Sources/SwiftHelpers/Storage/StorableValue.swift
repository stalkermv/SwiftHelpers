//
//  Created by Valeriy Malishevskyi on 25.07.2022.
//

import Foundation
import SwiftUI

/// A property wrapper that stores a value in a `Storage` object.
///
/// The `StorableValue` property wrapper allows a value to be stored in a `Storage` object,
/// which can be any object that conforms to the `Storage` protocol.
/// The value is automatically loaded from the storage object when the property is accessed,
/// and is saved to the storage object when the property is set.
///
/// The `StorableValue` property wrapper is generic over a type `T` that conforms to `Codable`.
///
/// - Note: The `StorableValue` property wrapper uses an `EquatableNoop` property wrapper
/// to make the `Storage` object conform to `Equatable` without adding any additional logic.
@propertyWrapper
public struct StorableValue<T: Codable> : DynamicProperty {
    public var defaultValue: T
    public var key: String
    @EquatableNoop public var storage: Storage
    private var inMemoryValue: T

    public init(wrappedValue: T, key: String, in storage: Storage) {
        self.key = key
        self.defaultValue = wrappedValue
        self.storage = storage
        self.inMemoryValue = defaultValue
        self.wrappedValue = (try? storage.load(key: key)) ?? defaultValue
    }

    public init<K: RawRepresentable>(wrappedValue: T, key: K, in storage: Storage) where K.RawValue == String {
        self.init(wrappedValue: wrappedValue, key: key.rawValue, in: storage)
    }

    public var wrappedValue: T  {
        get { inMemoryValue }
        set {
            inMemoryValue = newValue
            try? storage.save(newValue, key: key)
        }
    }
}

extension StorableValue: Equatable where T: Equatable {}
