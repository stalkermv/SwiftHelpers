//
//  KeychainSecureStorage.swift
//  SwiftUIHelpers
//
//  Created by Valeriy Malishevskyi on 04.09.2024.
//

import Foundation
import Combine

public final class KeychainSecureStorage {
    
    private let keychain: Keychain
    private let changePublisher = PassthroughSubject<String, Never>()
//    private let observers = KeychainObserverRegistry()
    
    /// Initialize with a default service name and access mode
    init(serviceName: String = Bundle.main.serviceName) {
        self.keychain = Keychain(
            serviceName: serviceName,
            accessMode: kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String
        )
    }
    
    @MainActor public static let shared = KeychainSecureStorage()
    
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
        changePublisher.send(key)
    }
    
    public func observe<T: Codable & Sendable>(key: String) -> AsyncThrowingStream<T, Error> {
        AsyncThrowingStream { continuation in
            do {
                let value = try self.value(type: T.self, forKey: key)
                continuation.yield(value)
            } catch {
                continuation.finish(throwing: error)
                return
            }
            
            let subscription = changePublisher
                .filter { $0 == key }
                .sink { _ in
                    if let value: T = try? self.value(type: T.self, forKey: key) {
                        continuation.yield(value)
                    }
                }
            
            continuation.onTermination = { @Sendable _ in
                subscription.cancel()
            }
        }
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
