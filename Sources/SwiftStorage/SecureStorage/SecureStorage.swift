#if canImport(SwiftUI)
import SwiftUI

private struct DefaultSecureStorageBackendKey: EnvironmentKey {
    static let defaultValue: (any SecureStorageBackend)? = nil
}

public extension EnvironmentValues {
    var defaultSecureStorageBackend: (any SecureStorageBackend)? {
        get { self[DefaultSecureStorageBackendKey.self] }
        set { self[DefaultSecureStorageBackendKey.self] = newValue }
    }
}

public extension View {
    func defaultSecureStorage(_ backend: any SecureStorageBackend) -> some View {
        environment(\.defaultSecureStorageBackend, backend)
    }
}

public extension Scene {
    func defaultSecureStorage(_ backend: any SecureStorageBackend) -> some Scene {
        environment(\.defaultSecureStorageBackend, backend)
    }
}

@propertyWrapper
@MainActor
public struct SecureStorage<Value>: DynamicProperty where Value: Codable & Sendable {
    @Environment(\.defaultSecureStorageBackend) private var environmentBackend
    @ObservedObject private var observedState: SecureStorageState<Value>

    private let state: SecureStorageState<Value>
    private let explicitBackend: (any SecureStorageBackend)?

    public init(
        _ key: String,
        defaultValue: Value,
        backend: (any SecureStorageBackend)? = nil
    ) {
        self.explicitBackend = backend
        let state = SecureStorageState(key: key, defaultValue: defaultValue)
        state.bind(to: backend ?? SystemSecureStorageBackend.shared)
        self.state = state
        self._observedState = ObservedObject(wrappedValue: state)
    }

    public var wrappedValue: Value {
        get { state.value }
        nonmutating set { state.setValue(newValue) }
    }

    public var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }

    public var error: Error? {
        state.error
    }

    public nonisolated mutating func update() {
        MainActor.assumeIsolated {
            _environmentBackend.update()
            _observedState.update()
            state.bind(to: explicitBackend ?? environmentBackend ?? SystemSecureStorageBackend.shared)
        }
    }
}

extension SecureStorage where Value: ExpressibleByNilLiteral {
    public init(_ key: String, backend: (any SecureStorageBackend)? = nil) {
        self.init(key, defaultValue: nil, backend: backend)
    }
}
#endif
