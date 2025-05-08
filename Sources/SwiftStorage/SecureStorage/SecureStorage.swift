//
//  SecureStorage.swift
//  SwiftUIHelpers
//
//  Created by Valeriy Malishevskyi on 04.09.2024.
//

import SwiftUI
import FoundationExtensions

@propertyWrapper @MainActor
public struct SecureStorage<Value>: DynamicProperty where Value: Codable {
    
    final class Container {
        /// Inicates that object installed on a View
        var installed = false
    }
    
    private let key: String
    private let defaultValue: Value
    private let storage: SecureStorageService
    private let container = Container()
    
    @StateObject private var state = State()
    
    public init(_ key: String, defaultValue: Value, store: SecureStorageService = KeychainSecureStorage.shared) {
        self.key = key
        self.defaultValue = defaultValue
        
        if ProcessInfo.isPreview {
            self.storage = InMemorySecureStorage.shared
        } else {
            self.storage = store
        }
    }
    
    public var wrappedValue: Value {
        get {
            do {
                let value = try storage.value(type: Value.self, forKey: key)
                return value
            } catch {
                print("Failed to get value for key \(key): \(error)")
                return defaultValue
            }
        }
        
        nonmutating set {
            do {
                if container.installed { state.objectWillChange.send() }
                
                try storage.set(newValue, forKey: key)
            } catch {
                print("Failed to set value for key \(key): \(error)")
            }
        }
    }
    
    nonisolated public func update() {
        DispatchQueue.main.async {
            _update()
        }
    }
    
    func _update() {
        guard !container.installed else { return }
        defer { container.installed = true }
        
        let subscription = Subscription(key: key) { [state] in
            state.objectWillChange.send()
        }
        
        self.storage.subscribe(subscription: subscription)
        
        self.state.subscriberState.unsubscribe = {
            storage.unsubscribe(subscription: subscription) // TODO: Implement unsubscribe
        }
    }
}

extension SecureStorage where Value: ExpressibleByNilLiteral {
    public init(_ key: String, store: SecureStorageService = KeychainSecureStorage.shared) {
        self.init(key, defaultValue: nil, store: store)
    }
}

extension SecureStorage {
    @MainActor final class State: ObservableObject {
        let subscriberState = SubscriberState()
    }
}

@MainActor internal final class SubscriberState {
    var unsubscribe: (@MainActor () -> Void)?
  
    deinit {
        Task(priority: .high) { @MainActor [unsubscribe] in
            unsubscribe?()
        }
    }
}

