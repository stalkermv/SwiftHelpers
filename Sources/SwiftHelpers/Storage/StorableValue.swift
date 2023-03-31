//
//  Created by Valeriy Malishevskyi on 25.07.2022.
//

import Foundation

@propertyWrapper
public struct StorableValue<T: Codable> {
    public var defaultValue: T
    public var key: String
    @EquatableNoop public var storage: Storage
    private var inMemoryValue: T

    public init(wrappedValue: T, key: String, storage: Storage) {
        self.key = key
        self.defaultValue = wrappedValue
        self.storage = storage
        self.inMemoryValue = defaultValue
        self.wrappedValue = (try? storage.load(key: key)) ?? defaultValue
    }

    public init<K: RawRepresentable>(wrappedValue: T, key: K, storage: Storage) where K.RawValue == String {
        self.init(wrappedValue: wrappedValue, key: key.rawValue, storage: storage)
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
