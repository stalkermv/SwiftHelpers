//
//  AppStorageKey.swift
//  SwiftUIHelpers
//
//  Created by Valeriy Malishevskyi on 02.09.2024.
//

import SwiftUI
import FoundationExtensions

public protocol AppStorageKey {
    associatedtype Value
    static var defaultValue: Value { get }
}

extension AppStorageKey where Value: ExpressibleByNilLiteral {
    public static var defaultValue: Value {
        nil
    }
}

extension AppStorageKey {
    static var key: String {
        String(describing: Self.self)
    }
}

extension AppStorage {
    public init<K: AppStorageKey>(_ key: K, store: UserDefaults? = nil) where Value == K.Value, K.Value == String {
        self.init(wrappedValue: K.defaultValue, K.key, store: store)
    }
    
    public init<K: AppStorageKey>(_ key: K, store: UserDefaults? = nil) where Value == K.Value, K.Value == URL {
        self.init(wrappedValue: K.defaultValue, K.key, store: store)
    }
    
    public init<K: AppStorageKey>(_ key: K, store: UserDefaults? = nil) where Value == K.Value, K.Value == Int {
        self.init(wrappedValue: K.defaultValue, K.key, store: store)
    }
    
    public init<K: AppStorageKey>(_ key: K, store: UserDefaults? = nil) where Value == K.Value, K.Value == Double {
        self.init(wrappedValue: K.defaultValue, K.key, store: store)
    }
    
    public init<K: AppStorageKey>(_ key: K, store: UserDefaults? = nil) where Value == K.Value, K.Value: RawRepresentable, K.Value.RawValue == String {
        self.init(wrappedValue: K.defaultValue, K.key, store: store)
    }
}

extension AppStorage where Value: ExpressibleByNilLiteral {
    public init<K: AppStorageKey>(_ key: K, store: UserDefaults? = nil) where Value == K.Value, K.Value == String? {
        self.init(K.key, store: store)
    }
    
    public init<K: AppStorageKey>(_ key: K, store: UserDefaults? = nil) where Value == K.Value, K.Value == URL? {
        self.init(K.key, store: store)
    }
    
    public init<K: AppStorageKey>(_ key: K, store: UserDefaults? = nil) where Value == K.Value, K.Value == Int? {
        self.init(K.key, store: store)
    }
    
    public init<K: AppStorageKey>(_ key: K, store: UserDefaults? = nil) where Value == K.Value, K.Value == Double? {
        self.init(K.key, store: store)
    }
    
    @available(iOS 15.0, *)
    public init<K, R>(_ key: K, store: UserDefaults? = nil)
    where Value == R?, R : RawRepresentable, R.RawValue == String, K: AppStorageKey, K.Value == R? {
        self.init(K.key, store: store)
    }
}

import Combine

extension UserDefaults {
    /// Creates a publisher for changes to the specified `key` in `UserDefaults`.
    public func publisher<Value>(for key: String) -> AnyPublisher<Value, Never> where Value: RawRepresentable {
        Just(value(forKey: key) as? Value.RawValue)
            .merge(
                with: NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
                    .compactMap { $0.object as? UserDefaults }
                    .map { $0.value(forKey: key) as? Value.RawValue }
            )
            .compactMap { $0 }
            .map(Value.init)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}

extension UserDefaults {
    /// Creates a publisher for changes to the specified key, using an `AppStorageKey` type.
    public func publisher<K: AppStorageKey>(for key: K) -> AnyPublisher<K.Value, Never> where K.Value: RawRepresentable {
        publisher(for: K.key)
            .map { $0 ?? K.defaultValue } // Use the default value if the key does not exist
            .eraseToAnyPublisher()
    }
    
    public func publisher<K: AppStorageKey>(for key: K) -> AnyPublisher<K.Value.Wrapped, Never>
    where K.Value: OptionalProtocol, K.Value.Wrapped: RawRepresentable {
        publisher(for: K.key)
            .eraseToAnyPublisher()
    }
}
