//
//  InMemorySecureStorage.swift
//  SwiftUIHelpers
//
//  Created by Valeriy Malishevskyi on 08.09.2024.
//

import Foundation
import Combine

public final class InMemorySecureStorage {
    
    private let storage = NSCache<NSString, NSData>()
    private let changePublisher = PassthroughSubject<String, Never>()
    
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
        
        storage.setObject(data as NSData, forKey: key as NSString)
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
