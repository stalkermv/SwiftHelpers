//
//  InMemorySecureStorage.swift
//  SwiftUIHelpers
//
//  Created by Valeriy Malishevskyi on 08.09.2024.
//

import Foundation

public final class InMemorySecureStorage {
    
    private let storage = NSCache<NSString, NSData>()
    private var subscriptions: [Subscription] = []
    
    /// Initialize with a default service name and access mode
    private init() {}
    
    @MainActor public static let shared = InMemorySecureStorage()
    
    /// Convenience method to convert AnyHashable to String
    private func keyAsString(_ key: AnyHashable) -> String {
        guard let keyString = key as? String else {
            fatalError("Key must be a string")
        }
        return keyString
    }
}

extension InMemorySecureStorage: SecureStorageService {
    public func value<T>(type: T.Type, forKey key: String) throws -> T
    where T: Decodable {
        guard let data = storage.object(forKey: key as NSString) as Data? else {
            throw SecureStorageError.valueNotFound
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    public func set<T>(_ value: T, forKey key: String) throws where T: Encodable {
        guard let data = try? JSONEncoder().encode(value) else {
            throw SecureStorageError.encodingFailed
        }
        
        for subscription in subscriptions {
            Task {
                await subscription.update()
            }
        }
        
        storage.setObject(data as NSData, forKey: key as NSString)
    }
    
    public func subscribe(subscription: Subscription) {
        subscriptions.append(subscription)
        print("Subscribed to \(subscription.key)")
    }
    
    public func unsubscribe(subscription: Subscription) {
        subscriptions.removeAll { $0.key == subscription.key }
    }
}
