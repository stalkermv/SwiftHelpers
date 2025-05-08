//
//  StoredValue.swift
//  SwiftHelpers
//
//  Created by Valeriy Malishevskyi on 13.12.2024.
//

import SwiftUI

@propertyWrapper
public struct StoredValue<T> {
    
    final class Storage {
        var value: T
        
        init(value: T) {
            self.value = value
        }
    }
    
    private let storage: Storage
    
    public var wrappedValue: T {
        get { storage.value }
        nonmutating set { storage.value = newValue }
    }
    
    public init(wrappedValue: T) {
        storage = Storage(value: wrappedValue)
    }
}
