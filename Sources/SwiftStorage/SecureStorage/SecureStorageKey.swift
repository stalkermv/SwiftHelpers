//
//  SecureStorageKey.swift
//  SwiftUIHelpers
//
//  Created by Valeriy Malishevskyi on 04.09.2024.
//

public protocol SecureStorageKey {
    associatedtype Value: Codable
    static var defaultValue: Value { get }
}

extension SecureStorageKey where Value: ExpressibleByNilLiteral {
    public static var defaultValue: Value { nil }
}

extension SecureStorageKey {
    static var key: String {
        String(describing: Self.self)
    }
}

extension SecureStorage where Value: ExpressibleByNilLiteral {
    @MainActor
    public init<K: SecureStorageKey>(_ key: K, store: SecureStorageService = KeychainSecureStorage.shared) where Value == K.Value {
        self.init(K.key, defaultValue: K.defaultValue, store: store)
    }
}

extension SecureStorage {
    @MainActor
    public init<K: SecureStorageKey>(_ key: K, store: SecureStorageService = KeychainSecureStorage.shared) where Value == K.Value {
        self.init(K.key, defaultValue: K.defaultValue, store: store)
    }
}
