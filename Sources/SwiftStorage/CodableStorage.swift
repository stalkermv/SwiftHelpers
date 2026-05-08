//
//  CodableStorage.swift
//  SwiftUIHelpers
//
//  Created by Valeriy Malishevskyi on 21.04.2026.
//

#if canImport(SwiftUI)
import Foundation
import SwiftUI

private final class CodableStorageValueBox<Value>: @unchecked Sendable {
    var value: Value

    init(_ value: Value) {
        self.value = value
    }
}

private final class CodableStorageCodec<Value: Swift.Codable>: @unchecked Sendable {
    func encode(_ value: Value) -> Data? {
        try? JSONEncoder().encode(value)
    }

    func decode(_ data: Data) -> Value? {
        try? JSONDecoder().decode(Value.self, from: data)
    }

    func encoded(_ value: Value) -> Data {
        encode(value) ?? Data()
    }
}

@propertyWrapper
public struct CodableAppStorage<Value: Swift.Codable>: DynamicProperty {
    @AppStorage private var data: Data
    private let cachedValue: CodableStorageValueBox<Value>
    private let codec: CodableStorageCodec<Value>

    public init(wrappedValue defaultValue: Value, _ key: String, store: UserDefaults? = nil) {
        self.codec = CodableStorageCodec()
        self.cachedValue = CodableStorageValueBox(defaultValue)
        self._data = AppStorage(
            wrappedValue: codec.encoded(defaultValue),
            key,
            store: store
        )
    }

    public init(_ key: String, store: UserDefaults? = nil) where Value: ExpressibleByNilLiteral {
        self.init(wrappedValue: nil, key, store: store)
    }

    public init<K: AppStorageKey>(_ key: K, store: UserDefaults? = nil) where K.Value == Value {
        self.init(wrappedValue: K.defaultValue, K.key, store: store)
    }

    public var wrappedValue: Value {
        get {
            guard let decoded = codec.decode(data) else { return cachedValue.value }
            cachedValue.value = decoded
            return decoded
        }

        nonmutating set {
            guard let encoded = codec.encode(newValue) else { return }
            cachedValue.value = newValue
            data = encoded
        }
    }

    public var projectedValue: Binding<Value> {
        let cachedValue = self.cachedValue
        let codec = self.codec
        let dataBinding = $data

        return Binding(
            get: {
                guard let decoded = codec.decode(dataBinding.wrappedValue) else { return cachedValue.value }
                cachedValue.value = decoded
                return decoded
            },
            set: { newValue in
                guard let encoded = codec.encode(newValue) else { return }
                cachedValue.value = newValue
                dataBinding.wrappedValue = encoded
            }
        )
    }
}

extension AppStorage {
    public typealias Codable = CodableAppStorage
}

@propertyWrapper
public struct CodableSceneStorage<Value: Swift.Codable>: DynamicProperty {
    @SceneStorage private var data: Data
    private let cachedValue: CodableStorageValueBox<Value>
    private let hasLocalWrite: CodableStorageValueBox<Bool>
    private let codec: CodableStorageCodec<Value>

    public init(wrappedValue defaultValue: Value, _ key: String) {
        self.codec = CodableStorageCodec()
        self.cachedValue = CodableStorageValueBox(defaultValue)
        self.hasLocalWrite = CodableStorageValueBox(false)
        self._data = SceneStorage(
            wrappedValue: codec.encoded(defaultValue),
            key
        )
    }

    public init(_ key: String) where Value: ExpressibleByNilLiteral {
        self.init(wrappedValue: nil, key)
    }

    public init<K: SceneStorageKey>(_ key: K) where K.Value == Value {
        self.init(wrappedValue: K.defaultValue, K.key)
    }

    public init<K>(_ keyPath: KeyPath<SceneStorageKeys, K>) where K: SceneStorageKey, K.Value == Value {
        self.init(wrappedValue: K.defaultValue, K.key)
    }

    public var wrappedValue: Value {
        get {
            guard hasLocalWrite.value == false else { return cachedValue.value }
            guard let decoded = codec.decode(data) else { return cachedValue.value }
            cachedValue.value = decoded
            return decoded
        }

        nonmutating set {
            guard let encoded = codec.encode(newValue) else { return }
            cachedValue.value = newValue
            hasLocalWrite.value = true
            data = encoded
        }
    }

    public var projectedValue: Binding<Value> {
        let cachedValue = self.cachedValue
        let codec = self.codec
        let dataBinding = $data
        let hasLocalWrite = self.hasLocalWrite

        return Binding(
            get: {
                guard hasLocalWrite.value == false else { return cachedValue.value }
                guard let decoded = codec.decode(dataBinding.wrappedValue) else { return cachedValue.value }
                cachedValue.value = decoded
                return decoded
            },
            set: { newValue in
                guard let encoded = codec.encode(newValue) else { return }
                cachedValue.value = newValue
                hasLocalWrite.value = true
                dataBinding.wrappedValue = encoded
            }
        )
    }
}

extension SceneStorage {
    public typealias Codable = CodableSceneStorage
}
#endif
