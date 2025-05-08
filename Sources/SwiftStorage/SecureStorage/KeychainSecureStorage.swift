//
//  KeychainSecureStorage.swift
//  SwiftUIHelpers
//
//  Created by Valeriy Malishevskyi on 04.09.2024.
//

import Foundation

public final class KeychainSecureStorage {
    
    private let keychain: Keychain
    
    /// Initialize with a default service name and access mode
    private init(serviceName: String = Bundle.main.serviceName) {
        self.keychain = Keychain(
            serviceName: serviceName,
            accessMode: kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String
        )
    }
    
    @MainActor public static let shared = KeychainSecureStorage()
    
    var subscriptions: [Subscription] = []
    
    /// Convenience method to convert AnyHashable to String
    private func keyAsString(_ key: AnyHashable) -> String {
        guard let keyString = key as? String else {
            fatalError("Key must be a string")
        }
        return keyString
    }
}

extension KeychainSecureStorage: SecureStorageService {
    public func value<T>(type: T.Type, forKey key: String) throws -> T
    where T: Decodable {
        guard let data = try keychain.getData(key: key) else {
            throw SecureStorageError.valueNotFound
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    public func set<T>(_ value: T, forKey key: String) throws where T: Encodable {
        guard let data = try? JSONEncoder().encode(value) else {
            throw SecureStorageError.encodingFailed
        }
        
        keychain.addOrUpdate(key: key, data: data)
        
        
        for subscription in subscriptions {
            subscription.update()
        }
    }
    
    public func subscribe(subscription: Subscription) {
        subscriptions.append(subscription)
    }
    
    public func unsubscribe(subscription: Subscription) {
        subscriptions.removeAll(where: { $0.key == subscription.key })
    }
}

enum SecureStorageError: Error {
    case valueNotFound
    case encodingFailed
}

public struct Subscription: Sendable {
    let key: String
    let update: @MainActor @Sendable () -> Void
    
    public init(key: String, update: @MainActor @escaping () -> Void) {
        self.key = key
        self.update = update
    }
}

extension Bundle {
    var serviceName: String {
        guard let bundleIdentifier = bundleIdentifier else {
            fatalError("Failed to get bundle identifier")
        }
        return bundleIdentifier
    }
}
