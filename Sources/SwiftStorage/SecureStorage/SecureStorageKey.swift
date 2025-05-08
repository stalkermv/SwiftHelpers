//
//  SecureStorageKey.swift
//  SwiftUIHelpers
//
//  Created by Valeriy Malishevskyi on 04.09.2024.
//

public protocol SecureStorageKey {
    associatedtype Value: Codable, ExpressibleByNilLiteral
    static var defaultValue: Value { get }
}

extension SecureStorageKey {
    public static var defaultValue: Value { nil }
}

extension SecureStorageKey {
    static var key: String {
        String(describing: Self.self)
    }
}

extension SecureStorage where Value: ExpressibleByNilLiteral {
    @MainActor
    public init<K: SecureStorageKey>(_ key: K, defaultValue: K.Value = nil, store: SecureStorageService = KeychainSecureStorage.shared) where Value == K.Value {
        self.init(K.key, defaultValue: defaultValue, store: store)
    }
}
