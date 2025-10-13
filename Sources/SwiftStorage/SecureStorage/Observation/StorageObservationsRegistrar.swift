//
//  StorageObservationsRegistrar.swift
//  SwiftHelpers
//
//  Created by Valeriy Malishevskyi on 13.10.2025.
//

import Foundation

@MainActor
final class StorageObservationsRegistrar {
    static let shared = StorageObservationsRegistrar()
    
    private var subscriptions: [String: AnyObject] = [:]
    
    func register<T: Codable>(_ observation: StorageObservableValue<T>, forKey key: String) {
        subscriptions[key] = observation
    }
    
    func unregister(forKey key: String) {
        subscriptions.removeValue(forKey: key)
    }
    
    func observation<T: Codable>(forKey key: String) -> StorageObservableValue<T>? {
        if let subscription = subscriptions[key] as? StorageObservableValue<T> {
            return subscription
        }
        return nil
    }
}
