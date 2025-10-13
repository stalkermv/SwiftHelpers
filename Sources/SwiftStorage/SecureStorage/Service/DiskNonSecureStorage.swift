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
    
    init(fileName: String, fileManager: FileManager = .default) throws {
        self.fileName = fileName
        self.fileManager = fileManager
        
        try createFileIfNeeded()
    }
    
    private func documentDirectoryURL() throws -> URL {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw SecureStorageError.documentDirectoryNotFound
        }
        return url
    }
    
    private func fileURL() throws -> URL {
        return try documentDirectoryURL().appendingPathComponent(fileName)
    }
    
    private func createFileIfNeeded() throws {
        let url = try fileURL()
        if !fileManager.fileExists(atPath: url.path) {
            // Initialize with empty dictionary
            let emptyDictionary: [String: Data] = [:]
            let data = try JSONEncoder().encode(emptyDictionary)
            try data.write(to: url)
        }
    }
    
    func value<T>(type: T.Type, forKey key: String) throws -> T where T : Decodable {
        let url = try fileURL()
        let data = try Data(contentsOf: url)
        
        // Decode the dictionary of key-value pairs
        let dictionary = try JSONDecoder().decode([String: Data].self, from: data)
        
        guard let keyData = dictionary[key] else {
            throw SecureStorageError.valueNotFound
        }
        
        return try JSONDecoder().decode(T.self, from: keyData)
    }

    func set<T>(_ value: T, forKey key: String) throws where T : Encodable {
        let url = try fileURL()
        
        // Read existing dictionary or create new one
        var dictionary: [String: Data] = [:]
        if fileManager.fileExists(atPath: url.path) {
            let data = try Data(contentsOf: url)
            dictionary = try JSONDecoder().decode([String: Data].self, from: data)
        }
        
        // Encode the new value and store it in the dictionary
        let valueData = try JSONEncoder().encode(value)
        dictionary[key] = valueData
        
        // Write the updated dictionary back to the file
        let dictionaryData = try JSONEncoder().encode(dictionary)
        try dictionaryData.write(to: url)
        
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
