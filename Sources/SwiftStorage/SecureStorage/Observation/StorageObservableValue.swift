//
//  StorageObservableValue.swift
//  SwiftHelpers
//
//  Created by Valeriy Malishevskyi on 13.10.2025.
//

import Foundation
import SwiftUI

@MainActor
final class StorageObservableValue<Value: Codable>: ObservableObject {
    let storage: SecureStorageService
    let key: String
    
    @Published private(set) var value: Value
    @Published var error: Error?
    
    var task: Task<Void, Error>?
    
    init(storage: SecureStorageService, key: String, initialValue value: Value) {
        self.storage = storage
        self.key = key
        self.value = value
    }
    
    func updateValue(_ newValue: Value) {
        do {
            self.value = newValue
            try storage.set(newValue, forKey: key)
        } catch {
            self.error = error
        }
    }
    
    func subscribe() {
        guard task == nil else { return }
        task = Task {
            for try await value in storage.observe(key: key) as AsyncStream<Value> {
                self.value = value
            }
        }
    }
}
