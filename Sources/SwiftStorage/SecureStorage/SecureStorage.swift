//
//  SecureStorage.swift
//  SwiftUIHelpers
//
//  Created by Valeriy Malishevskyi on 04.09.2024.
//

#if canImport(SwiftUI)
import SwiftUI
import FoundationExtensions

@propertyWrapper @MainActor
public struct SecureStorage<Value>: DynamicProperty where Value: Codable & Sendable {
    
    @StateObject private var observableValue: StorageObservableValue<Value>
    
    public init(
        _ key: String,
        defaultValue: Value,
        store: SecureStorageService = KeychainSecureStorage.shared
    ) {
        let storage: SecureStorageService
        if ProcessInfo.isPreview {
            #if DEBUG
            do {
                storage = try DiskNonSecureStorage(fileName: "preview_secure_storage.json")
            } catch {
                // Fallback to in-memory storage if document directory is not available
                storage = InMemorySecureStorage.shared
            }
            #else
            finalStore = store
            #endif
        } else {
            storage = store
        }
        let observableValue = StorageObservationsRegistrar.shared.observation(forKey: key)
        ?? StorageObservableValue(
            storage: storage,
            key: key,
            initialValue: defaultValue
        )
        StorageObservationsRegistrar.shared.register(observableValue, forKey: key)
        self._observableValue = StateObject(wrappedValue: observableValue)
    }
    
    public var wrappedValue: Value {
        get {
            observableValue.value
        }
        
        nonmutating set {
            observableValue.updateValue(newValue)
        }
    }
    
    public var error: Error? {
        observableValue.error
    }
    
    public nonisolated func update() {
        Task { @MainActor in
            observableValue.subscribe()
        }
    }
}

extension SecureStorage where Value: ExpressibleByNilLiteral {
    public init(_ key: String, store: SecureStorageService = KeychainSecureStorage.shared) {
        self.init(key, defaultValue: nil, store: store)
    }
}

#endif