//
//  SecureStorageService.swift
//  SwiftUIHelpers
//
//  Created by Valeriy Malishevskyi on 04.09.2024.
//

public protocol SecureStorageService {
    func value<T: Decodable>(type: T.Type, forKey key: String) throws -> T
    func set<T: Encodable>(_ value: T, forKey key: String) throws
    
    func observe<T: Codable & Sendable>(key: String) -> AsyncThrowingStream<T, Error>
}

extension SecureStorageService {
    public func observe<T: Codable & Sendable>(key: String) -> AsyncThrowingStream<T, Error> {
        AsyncThrowingStream { continuation in
            do {
                let value = try value(type: T.self, forKey: key)
                continuation.yield(value)
            } catch {
                continuation.finish(throwing: error)
                return
            }
            
            // Keep the stream alive for continuous observation
            // Subclasses should override this method to provide proper notification mechanism
            continuation.onTermination = { _ in
                // Stream terminated
            }
        }
    }
}
