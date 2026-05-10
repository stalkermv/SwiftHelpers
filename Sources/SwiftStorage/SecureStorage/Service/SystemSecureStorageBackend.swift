import Combine
import Dispatch
import Foundation
import FoundationExtensions

public final class SystemSecureStorageBackend: SecureStorageBackend {
    public static let shared = SystemSecureStorageBackend()

    public let namespace: String

    private let resolver: SecureStorageSystemResolver

    public init(namespace: String = Bundle.main.bundleIdentifier ?? "SwiftStorage") {
        self.namespace = namespace
        self.resolver = .shared
    }

    internal init(namespace: String, resolver: SecureStorageSystemResolver) {
        self.namespace = namespace
        self.resolver = resolver
    }

    public func data(forKey key: String) throws -> Data? {
        try resolvedBackend().data(forKey: key)
    }

    public func setData(_ data: Data?, forKey key: String) throws {
        try resolvedBackend().setData(data, forKey: key)
    }

    public func updates(forKey key: String) -> AnyPublisher<Void, Never> {
        resolvedBackend().updates(forKey: key)
    }

    internal func resolvedBackendForTesting() -> any SecureStorageBackend {
        resolvedBackend()
    }

    private func resolvedBackend() -> any SecureStorageBackend {
        resolver.backend(for: namespace)
    }
}

internal final class SecureStorageSystemResolver: Sendable {
    static let shared = SecureStorageSystemResolver()

    private let queue = DispatchQueue(label: "SwiftStorage.SystemSecureStorageResolver")
    nonisolated(unsafe) private var resolvedBackends: [String: any SecureStorageBackend] = [:]
    private let isPreview: @Sendable () -> Bool
    private let makeKeychain: @Sendable (String) -> any SecureStorageBackend
    private let makeFile: @Sendable (String) -> any SecureStorageBackend
    private let keychainAvailable: @Sendable (String) -> Bool

    init(
        isPreview: @escaping @Sendable () -> Bool = { ProcessInfo.processInfo.isPreview },
        makeKeychain: @escaping @Sendable (String) -> any SecureStorageBackend = { namespace in
            KeychainSecureStorageBackend(serviceName: namespace)
        },
        makeFile: @escaping @Sendable (String) -> any SecureStorageBackend = { namespace in
            FileSecureStorageBackend.temporary(namespace: namespace)
        },
        keychainAvailable: @escaping @Sendable (String) -> Bool = { namespace in
            KeychainSecureStorageBackend.canAccess(
                serviceName: namespace,
                accessMode: kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String
            )
        }
    ) {
        self.isPreview = isPreview
        self.makeKeychain = makeKeychain
        self.makeFile = makeFile
        self.keychainAvailable = keychainAvailable
    }

    func backend(for namespace: String) -> any SecureStorageBackend {
        queue.sync {
            if let backend = resolvedBackends[namespace] {
                return backend
            }

            let backend: any SecureStorageBackend
            if isPreview() {
                backend = makeFile(namespace)
            } else if keychainAvailable(namespace) {
                backend = makeKeychain(namespace)
            } else {
                backend = makeFile(namespace)
            }

            resolvedBackends[namespace] = backend
            return backend
        }
    }
}
