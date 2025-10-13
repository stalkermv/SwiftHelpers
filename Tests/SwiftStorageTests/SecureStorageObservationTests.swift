//
//  SecureStorageObservationTests.swift
//  SwiftHelpers
//
//  Created by Valeriy Malishevskyi on 13.10.2025.
//

import Testing
@testable import SwiftStorage

@MainActor
struct SecureStorageObservationTests {
    
    @Test func inMemorySecureStorageObservation() async throws {
        let storage = InMemorySecureStorage.shared
        
        // Set initial value
        try storage.set("initial", forKey: "test_key")
        
        // Create observation stream
        let stream = storage.observe(key: "test_key") as AsyncThrowingStream<String, Error>
        
        // Collect values from the stream
        var receivedValues: [String] = []
        let task = Task {
            do {
                for try await value in stream {
                    receivedValues.append(value)
                    // Stop after receiving 3 values
                    if receivedValues.count >= 3 {
                        break
                    }
                }
            } catch {
                Issue.record("Stream failed with error: \(error)")
            }
        }
        
        // Wait a bit for initial value
        try await Task.sleep(for: .milliseconds(10))
        
        // Update the value twice
        try storage.set("updated1", forKey: "test_key")
        try await Task.sleep(for: .milliseconds(10))
        
        try storage.set("updated2", forKey: "test_key")
        
        // Wait for the task to complete
        await task.value
        
        // Verify we received all expected values
        #expect(receivedValues.count == 3)
        #expect(receivedValues[0] == "initial")
        #expect(receivedValues[1] == "updated1")
        #expect(receivedValues[2] == "updated2")
    }
    
    @Test func keychainSecureStorageObservation() async throws {
        let storage = KeychainSecureStorage(serviceName: "TestKeychain")
        
        // Set initial value
        try storage.set("initial", forKey: "test_keychain_key")
        
        // Create observation stream
        let stream = storage.observe(key: "test_keychain_key") as AsyncThrowingStream<String, Error>
        
        // Collect values from the stream
        var receivedValues: [String] = []
        let task = Task {
            do {
                for try await value in stream {
                    receivedValues.append(value)
                    // Stop after receiving 3 values
                    if receivedValues.count >= 3 {
                        break
                    }
                }
            } catch {
                Issue.record("Stream failed with error: \(error)")
            }
        }
        
        // Wait a bit for initial value
        try await Task.sleep(for: .milliseconds(10))
        
        // Update the value twice
        try storage.set("updated1", forKey: "test_keychain_key")
        try await Task.sleep(for: .milliseconds(10))
        
        try storage.set("updated2", forKey: "test_keychain_key")
        
        // Wait for the task to complete
        await task.value
        
        // Verify we received all expected values
        #expect(receivedValues.count == 3)
        #expect(receivedValues[0] == "initial")
        #expect(receivedValues[1] == "updated1")
        #expect(receivedValues[2] == "updated2")
    }
    
    @Test func diskNonSecureStorageObservation() async throws {
        #if DEBUG
        let storage = try DiskNonSecureStorage(fileName: "test_observation.json")
        
        // Set initial value
        try storage.set("initial", forKey: "test_disk_key")
        
        // Create observation stream
        let stream = storage.observe(key: "test_disk_key") as AsyncStream<String>
        
        // Collect values from the stream
        var receivedValues: [String] = []
        let task = Task {
            for await value in stream {
                receivedValues.append(value)
                // Stop after receiving 3 values
                if receivedValues.count >= 3 {
                    break
                }
            }
        }
        
        // Wait a bit for initial value
        try await Task.sleep(for: .milliseconds(10))
        
        // Update the value twice
        try storage.set("updated1", forKey: "test_disk_key")
        try await Task.sleep(for: .milliseconds(10))
        
        try storage.set("updated2", forKey: "test_disk_key")
        
        // Wait for the task to complete
        await task.value
        
        // Verify we received all expected values
        #expect(receivedValues.count == 3)
        #expect(receivedValues[0] == "initial")
        #expect(receivedValues[1] == "updated1")
        #expect(receivedValues[2] == "updated2")
        #endif
    }
}
