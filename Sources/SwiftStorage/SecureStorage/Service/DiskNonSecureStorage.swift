//
//  DiskNonSecureStorage.swift
//  SwiftHelpers
//
//  Created by Valeriy Malishevskyi on 13.10.2025.
//

import Foundation
import Combine

#if DEBUG
struct DiskNonSecureStorage: SecureStorageService {

    let fileName: String
    let fileManager: FileManager
    
    let changePublisher = PassthroughSubject<String, Never>()
    
    init(fileName: String, fileManager: FileManager = .default) {
        self.fileName = fileName
        self.fileManager = fileManager
        
        createFileIfNeeded()
    }
    
    private func createFileIfNeeded() {
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
        if !fileManager.fileExists(atPath: url.path) {
            try? Data().write(to: url)
        }
    }
    
    func value<T>(type: T.Type, forKey key: String) throws -> T where T : Decodable {
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

    func set<T>(_ value: T, forKey key: String) throws where T : Encodable {
        let data = try JSONEncoder().encode(value)
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
        try data.write(to: url)
        
        changePublisher.send(key)
    }
    
    func observe<T: Sendable>(key: String) -> AsyncStream<T> where T : Decodable, T : Encodable {
        AsyncStream { continuation in
            do {
                try continuation.yield(self.value(type: T.self, forKey: key))
            } catch {
                print("Failed to yield initial value for key \(key): \(error)")
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
#endif

extension AnyCancellable: @unchecked @retroactive Sendable {}
