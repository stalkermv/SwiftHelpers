//  MIT License
//
//  Copyright (c) 2023 Maksym Kuznietsov
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Valeriy Malishevskyi on 25.07.2022.
//

import Foundation
import SwiftUI

/// A property wrapper that stores a value in a `Storage` object.
///
/// The `StorableValue` property wrapper allows a value to be stored in a `Storage` object,
/// which can be any object that conforms to the `Storage` protocol.
/// The value is automatically loaded from the storage object when the property is accessed,
/// and is saved to the storage object when the property is set.
///
/// The `StorableValue` property wrapper is generic over a type `T` that conforms to `Codable`.
///
/// - Note: The `StorableValue` property wrapper uses an `EquatableNoop` property wrapper
/// to make the `Storage` object conform to `Equatable` without adding any additional logic.
@propertyWrapper
public struct StorableValue<T: Codable> : DynamicProperty {
    public var defaultValue: T
    public var key: String
    @EquatableNoop public var storage: Storage
    private var inMemoryValue: T

    public init(wrappedValue: T, key: String, in storage: Storage) {
        self.key = key
        self.defaultValue = wrappedValue
        self.storage = storage
        self.inMemoryValue = defaultValue
        self.wrappedValue = (try? storage.load(key: key)) ?? defaultValue
    }

    public init<K: RawRepresentable>(wrappedValue: T, key: K, in storage: Storage) where K.RawValue == String {
        self.init(wrappedValue: wrappedValue, key: key.rawValue, in: storage)
    }

    public var wrappedValue: T  {
        get { inMemoryValue }
        set {
            inMemoryValue = newValue
            try? storage.save(newValue, key: key)
        }
    }
}

extension StorableValue: Equatable where T: Equatable {}
