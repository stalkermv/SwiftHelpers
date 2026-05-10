#if canImport(SwiftUI)
import Combine
import Foundation
import Testing
@testable import SwiftStorage

private func secureStorageData(_ string: String) -> Data {
    Data(string.utf8)
}

@MainActor
struct SecureStorageBackendTests {
    @Test func inMemoryBackendReadWriteRemoveAndUpdates() throws {
        let backend = InMemorySecureStorageBackend(scope: UUID().uuidString)
        var updateCount = 0
        let cancellable = backend.updates(forKey: "token").sink { updateCount += 1 }
        defer { cancellable.cancel() }

        #expect(try backend.data(forKey: "token") == nil)

        try backend.setData(secureStorageData("first"), forKey: "token")
        #expect(try backend.data(forKey: "token") == secureStorageData("first"))

        try backend.setData(nil, forKey: "token")
        #expect(try backend.data(forKey: "token") == nil)
        #expect(updateCount == 2)
    }

    @Test func keychainBackendReadWriteRemoveAndUpdates() throws {
        let backend = KeychainSecureStorageBackend(serviceName: "SwiftHelpers.Tests.\(UUID().uuidString)")
        var updateCount = 0
        let cancellable = backend.updates(forKey: "secret").sink { updateCount += 1 }
        defer {
            cancellable.cancel()
            try? backend.setData(nil, forKey: "secret")
        }

        #expect(try backend.data(forKey: "secret") == nil)

        try backend.setData(secureStorageData("value"), forKey: "secret")
        #expect(try backend.data(forKey: "secret") == secureStorageData("value"))

        try backend.setData(nil, forKey: "secret")
        #expect(try backend.data(forKey: "secret") == nil)
        #expect(updateCount == 2)
    }

    @Test func fileBackendReadWriteRemoveAndUpdates() throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("SwiftHelpersTests")
            .appendingPathComponent("\(UUID().uuidString).json")
        let backend = FileSecureStorageBackend(fileURL: fileURL)
        var updateCount = 0
        let cancellable = backend.updates(forKey: "token").sink { updateCount += 1 }
        defer {
            cancellable.cancel()
            try? FileManager.default.removeItem(at: fileURL)
        }

        #expect(try backend.data(forKey: "token") == nil)

        try backend.setData(secureStorageData("disk"), forKey: "token")
        #expect(try backend.data(forKey: "token") == secureStorageData("disk"))

        try backend.setData(nil, forKey: "token")
        #expect(try backend.data(forKey: "token") == nil)
        #expect(updateCount == 2)
        #expect(fileURL.deletingLastPathComponent().lastPathComponent == "SwiftHelpersTests")
    }
}
#endif
