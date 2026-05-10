public protocol SecureStorageKey {
    associatedtype Value: Codable & Sendable
    static var defaultValue: Value { get }
}

extension SecureStorageKey where Value: ExpressibleByNilLiteral {
    public static var defaultValue: Value { nil }
}

extension SecureStorageKey {
    static var key: String {
        String(describing: Self.self)
    }
}

extension SecureStorage where Value: ExpressibleByNilLiteral {
    @MainActor
    public init<K: SecureStorageKey>(_ key: K, backend: (any SecureStorageBackend)? = nil) where Value == K.Value {
        self.init(K.key, defaultValue: K.defaultValue, backend: backend)
    }
}

extension SecureStorage {
    @MainActor
    public init<K: SecureStorageKey>(_ key: K, backend: (any SecureStorageBackend)? = nil) where Value == K.Value {
        self.init(K.key, defaultValue: K.defaultValue, backend: backend)
    }
}
