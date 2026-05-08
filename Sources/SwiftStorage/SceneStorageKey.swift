//
//  SceneStorageKey.swift
//  SwiftUIHelpers
//
//  Created by Valeriy Malishevskyi on 21.04.2026.
//

#if canImport(SwiftUI)
import SwiftUI

public protocol SceneStorageKey {
    associatedtype Value
    static var defaultValue: Value { get }
}

extension SceneStorageKey where Value: ExpressibleByNilLiteral {
    public static var defaultValue: Value {
        nil
    }
}

extension SceneStorageKey {
    static var key: String {
        String(describing: Self.self)
    }
}

public struct SceneStorageKeys {
    public init() {}
}

extension SceneStorage {
    public init<K>(_ keyPath: KeyPath<SceneStorageKeys, K>) where Value == K.Value, K: SceneStorageKey, K.Value == String {
        self.init(wrappedValue: K.defaultValue, K.key)
    }

    public init<K>(_ keyPath: KeyPath<SceneStorageKeys, K>) where Value == K.Value, K: SceneStorageKey, K.Value == URL {
        self.init(wrappedValue: K.defaultValue, K.key)
    }

    public init<K>(_ keyPath: KeyPath<SceneStorageKeys, K>) where Value == K.Value, K: SceneStorageKey, K.Value == Int {
        self.init(wrappedValue: K.defaultValue, K.key)
    }

    public init<K>(_ keyPath: KeyPath<SceneStorageKeys, K>) where Value == K.Value, K: SceneStorageKey, K.Value == Double {
        self.init(wrappedValue: K.defaultValue, K.key)
    }

    public init<K>(_ keyPath: KeyPath<SceneStorageKeys, K>) where Value == K.Value, K: SceneStorageKey, K.Value == Bool {
        self.init(wrappedValue: K.defaultValue, K.key)
    }

    public init<K>(_ keyPath: KeyPath<SceneStorageKeys, K>) where Value == K.Value, K: SceneStorageKey, K.Value: RawRepresentable, K.Value.RawValue == String {
        self.init(wrappedValue: K.defaultValue, K.key)
    }
}

extension SceneStorage where Value: ExpressibleByNilLiteral {
    public init<K>(_ keyPath: KeyPath<SceneStorageKeys, K>) where Value == K.Value, K: SceneStorageKey, K.Value == String? {
        self.init(K.key)
    }

    public init<K>(_ keyPath: KeyPath<SceneStorageKeys, K>) where Value == K.Value, K: SceneStorageKey, K.Value == URL? {
        self.init(K.key)
    }

    public init<K>(_ keyPath: KeyPath<SceneStorageKeys, K>) where Value == K.Value, K: SceneStorageKey, K.Value == Int? {
        self.init(K.key)
    }

    public init<K>(_ keyPath: KeyPath<SceneStorageKeys, K>) where Value == K.Value, K: SceneStorageKey, K.Value == Bool? {
        self.init(K.key)
    }

    public init<K>(_ keyPath: KeyPath<SceneStorageKeys, K>) where Value == K.Value, K: SceneStorageKey, K.Value == Double? {
        self.init(K.key)
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    public init<K, R>(_ keyPath: KeyPath<SceneStorageKeys, K>)
    where Value == R?, R: RawRepresentable, R.RawValue == String, K: SceneStorageKey, K.Value == R? {
        self.init(K.key)
    }
}
#endif
