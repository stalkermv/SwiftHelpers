#if canImport(SwiftUI)
import Foundation
import SwiftUI
import os

private extension Logger {
    static let sceneStorage = Logger(subsystem: "SwiftStorage", category: "SceneStorage")
}

@MainActor
final class CodableSceneStorageCache<Value: Swift.Codable>: ObservableObject {
    private var entry: (key: String, data: Data, value: Value)?

    nonisolated init() {}

    func decode(_ data: Data, forKey key: String) -> Value? {
        if let entry, entry.key == key, entry.data == data {
            return .some(entry.value)
        }
        do {
            let value = try JSONDecoder().decode(Value.self, from: data)
            entry = (key, data, value)
            return .some(value)
        } catch {
            return nil
        }
    }

    func encode(_ value: Value) -> Data? {
        do {
            let data = try JSONEncoder().encode(value)
            entry = nil
            return data
        } catch {
            Logger.sceneStorage.error("SceneStorage Codable value could not be encoded; write rejected.")
            return nil
        }
    }

    func binding(to data: Binding<Data>, key: String, defaultValue: Value) -> Binding<Value> {
        Binding(
            get: { self.decode(data.wrappedValue, forKey: key) ?? defaultValue },
            set: { value, transaction in
                guard let bytes = self.encode(value) else { return }
                data.transaction(transaction).wrappedValue = bytes
            }
        )
    }
}

/// Stores a small Codable UI value in the current SwiftUI scene using standard JSON.
///
/// Reads always consult native scene bytes. Successful decoding is memoized while
/// the key and bytes match; missing or invalid bytes return the declared default.
/// Successful assignments clear the memoized value, even when bytes are unchanged.
/// Reference values may retain their identity between reads. Mutating a reference
/// without assigning through this property does not persist it.
@propertyWrapper
public struct CodableSceneStorage<Value: Swift.Codable>: DynamicProperty {
    @SceneStorage private var data: Data
    @StateObject private var cache = CodableSceneStorageCache<Value>()
    private let defaultValue: Value
    private let key: String

    public init(wrappedValue defaultValue: Value, _ key: String) {
        self.defaultValue = defaultValue
        self.key = key
        self._data = SceneStorage(wrappedValue: Data(), key)
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

    @MainActor public var wrappedValue: Value {
        get { cache.decode(data, forKey: key) ?? defaultValue }
        nonmutating set {
            guard let bytes = cache.encode(newValue) else { return }
            data = bytes
        }
    }

    @MainActor public var projectedValue: Binding<Value> {
        cache.binding(to: $data, key: key, defaultValue: defaultValue)
    }
}

extension SceneStorage {
    public typealias Codable = CodableSceneStorage
}
#endif
