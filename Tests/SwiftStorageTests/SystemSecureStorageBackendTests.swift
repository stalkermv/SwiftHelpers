#if canImport(SwiftUI)
import Combine
import Dispatch
import Foundation
import Testing
@testable import SwiftStorage

private final class ResolverProbeBackend: SecureStorageBackend {
    let name: String

    init(name: String) {
        self.name = name
    }

    func data(forKey key: String) throws -> Data? { nil }
    func setData(_ data: Data?, forKey key: String) throws {}
    func updates(forKey key: String) -> AnyPublisher<Void, Never> { Empty().eraseToAnyPublisher() }
}

private final class ResolverFlag: Sendable {
    private let queue = DispatchQueue(label: "SwiftStorageTests.ResolverFlag")
    nonisolated(unsafe) private var value: Bool

    init(_ value: Bool) {
        self.value = value
    }

    func read() -> Bool {
        queue.sync { value }
    }

    func write(_ newValue: Bool) {
        queue.sync { value = newValue }
    }
}

struct SystemSecureStorageBackendTests {
    @Test func previewSelectsFileBackend() {
        let resolver = SecureStorageSystemResolver(
            isPreview: { true },
            makeKeychain: { _ in ResolverProbeBackend(name: "keychain") },
            makeFile: { _ in ResolverProbeBackend(name: "file") },
            keychainAvailable: { _ in true }
        )
        let backend = SystemSecureStorageBackend(namespace: "preview", resolver: resolver)
            .resolvedBackendForTesting()

        #expect((backend as? ResolverProbeBackend)?.name == "file")
    }

    @Test func nonPreviewSelectsKeychainWhenProbeSucceeds() {
        let resolver = SecureStorageSystemResolver(
            isPreview: { false },
            makeKeychain: { _ in ResolverProbeBackend(name: "keychain") },
            makeFile: { _ in ResolverProbeBackend(name: "file") },
            keychainAvailable: { _ in true }
        )
        let backend = SystemSecureStorageBackend(namespace: "keychain", resolver: resolver)
            .resolvedBackendForTesting()

        #expect((backend as? ResolverProbeBackend)?.name == "keychain")
    }

    @Test func nonPreviewFallsBackToFileWhenProbeFails() {
        let resolver = SecureStorageSystemResolver(
            isPreview: { false },
            makeKeychain: { _ in ResolverProbeBackend(name: "keychain") },
            makeFile: { _ in ResolverProbeBackend(name: "file") },
            keychainAvailable: { _ in false }
        )
        let backend = SystemSecureStorageBackend(namespace: "fallback", resolver: resolver)
            .resolvedBackendForTesting()

        #expect((backend as? ResolverProbeBackend)?.name == "file")
    }

    @Test func resolverStaysStableAfterFirstChoice() {
        let flag = ResolverFlag(false)
        let resolver = SecureStorageSystemResolver(
            isPreview: { false },
            makeKeychain: { _ in ResolverProbeBackend(name: "keychain") },
            makeFile: { _ in ResolverProbeBackend(name: "file") },
            keychainAvailable: { _ in flag.read() }
        )
        let backend = SystemSecureStorageBackend(namespace: "stable", resolver: resolver)

        let first = backend.resolvedBackendForTesting()
        flag.write(true)
        let second = backend.resolvedBackendForTesting()

        #expect(first === second)
        #expect((second as? ResolverProbeBackend)?.name == "file")
    }
}
#endif
