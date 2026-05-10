#if canImport(AppKit) && canImport(SwiftUI)
import AppKit
import Foundation
import SwiftUI
import Testing
@testable import SwiftStorage

@MainActor
private final class SecureStorageRecorder<Value: Equatable & Sendable> {
    private(set) var values: [Value] = []

    func record(_ value: Value) {
        if values.last != value {
            values.append(value)
        }
    }
}

@MainActor
private final class SecureStorageHost<Content: View> {
    let controller: NSHostingController<Content>
    let window: NSWindow

    init(rootView: Content) {
        controller = NSHostingController(rootView: rootView)
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 32, height: 32),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )
        window.contentViewController = controller
        window.orderFront(nil)
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
    }

}

private enum WaitError: Error {
    case timedOut
}

private func jsonData<T: Encodable>(_ value: T) throws -> Data {
    try JSONEncoder().encode(value)
}

@MainActor
private func waitUntil(
    timeout: TimeInterval = 2,
    interval: TimeInterval = 0.01,
    _ condition: @escaping @MainActor () -> Bool
) async throws {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
        if condition() {
            return
        }
        try await Task.sleep(for: .milliseconds(Int(interval * 1_000)))
        await Task.yield()
    }
    throw WaitError.timedOut
}

private struct SecureStorageProbeView<Value: Codable & Sendable & Equatable>: View {
    @SecureStorage private var value: Value
    private let recorder: SecureStorageRecorder<Value>

    init(
        key: String,
        defaultValue: Value,
        backend: (any SecureStorageBackend)? = nil,
        recorder: SecureStorageRecorder<Value>
    ) {
        self.recorder = recorder
        if let backend {
            self._value = SecureStorage(key, defaultValue: defaultValue, backend: backend)
        } else {
            self._value = SecureStorage(key, defaultValue: defaultValue)
        }
    }

    var body: some View {
        let currentValue = value
        recorder.record(currentValue)
        return Color.clear.frame(width: 1, height: 1)
    }
}

private struct EnvironmentSecureStorageProbeView: View {
    @SecureStorage("environment-key", defaultValue: "default") private var value: String
    let recorder: SecureStorageRecorder<String>

    var body: some View {
        let currentValue = value
        recorder.record(currentValue)
        return Color.clear.frame(width: 1, height: 1)
    }
}

private struct SceneSecureStorageCompileScene: Scene {
    let backend = InMemorySecureStorageBackend(scope: "scene-compile")

    var body: some Scene {
        WindowGroup {
            Text("scene")
        }
        .defaultSecureStorage(backend)
    }
}

@MainActor
struct SecureStorageWrapperTests {
    @Test func defaultValueIsUsedWhenMissing() {
        let backend = InMemorySecureStorageBackend(scope: UUID().uuidString)
        let storage = SecureStorage<String>("greeting", defaultValue: "hello", backend: backend)

        #expect(storage.wrappedValue == "hello")
    }

    @Test func projectedBindingWritesThrough() throws {
        let backend = InMemorySecureStorageBackend(scope: UUID().uuidString)
        let storage = SecureStorage<String>("binding", defaultValue: "default", backend: backend)

        storage.projectedValue.wrappedValue = "updated"
        let expectedData = try jsonData("updated")

        #expect(storage.wrappedValue == "updated")
        #expect(try backend.data(forKey: "binding") == expectedData)
    }

    @Test func optionalNilRemovesStoredValue() throws {
        let backend = InMemorySecureStorageBackend(scope: UUID().uuidString)
        let storage = SecureStorage<String?>("optional", backend: backend)
        let expectedData = try jsonData("secret")

        storage.wrappedValue = "secret"
        #expect(try backend.data(forKey: "optional") == expectedData)

        storage.wrappedValue = nil
        #expect(storage.wrappedValue == nil)
        #expect(try backend.data(forKey: "optional") == nil)
    }

    @Test func twoWrappersOnSameKeyBackendStayInSync() async throws {
        let backend = InMemorySecureStorageBackend(scope: UUID().uuidString)
        let firstRecorder = SecureStorageRecorder<String>()
        let secondRecorder = SecureStorageRecorder<String>()
        let host = SecureStorageHost(rootView:
            VStack {
                SecureStorageProbeView(
                    key: "shared",
                    defaultValue: "default",
                    backend: backend,
                    recorder: firstRecorder
                )
                SecureStorageProbeView(
                    key: "shared",
                    defaultValue: "default",
                    backend: backend,
                    recorder: secondRecorder
                )
            }
        )
        _ = host

        try await waitUntil {
            firstRecorder.values == ["default"] && secondRecorder.values == ["default"]
        }

        try backend.setData(try jsonData("updated"), forKey: "shared")

        try await waitUntil {
            firstRecorder.values.last == "updated" && secondRecorder.values.last == "updated"
        }
    }

    @Test func sameKeyDifferentBackendsDoNotCrossTalk() async throws {
        let firstBackend = InMemorySecureStorageBackend(scope: UUID().uuidString)
        let secondBackend = InMemorySecureStorageBackend(scope: UUID().uuidString)
        let firstRecorder = SecureStorageRecorder<String>()
        let secondRecorder = SecureStorageRecorder<String>()
        let host = SecureStorageHost(rootView:
            VStack {
                SecureStorageProbeView(
                    key: "same-key",
                    defaultValue: "first-default",
                    backend: firstBackend,
                    recorder: firstRecorder
                )
                SecureStorageProbeView(
                    key: "same-key",
                    defaultValue: "second-default",
                    backend: secondBackend,
                    recorder: secondRecorder
                )
            }
        )
        _ = host

        try await waitUntil {
            firstRecorder.values == ["first-default"] && secondRecorder.values == ["second-default"]
        }

        try firstBackend.setData(try jsonData("first-only"), forKey: "same-key")
        try await waitUntil { firstRecorder.values.last == "first-only" }
        try await Task.sleep(for: .milliseconds(50))

        #expect(secondRecorder.values == ["second-default"])
    }

    @Test func missingInitialValueDoesNotKillObservation() async throws {
        let backend = InMemorySecureStorageBackend(scope: UUID().uuidString)
        let recorder = SecureStorageRecorder<String>()
        let host = SecureStorageHost(rootView: SecureStorageProbeView(
            key: "missing",
            defaultValue: "default",
            backend: backend,
            recorder: recorder
        ))
        _ = host

        try await waitUntil { recorder.values == ["default"] }

        try backend.setData(try jsonData("later"), forKey: "missing")
        try await waitUntil { recorder.values.last == "later" }
    }

    @Test func environmentDefaultBackendIsUsed() async throws {
        let backend = InMemorySecureStorageBackend(scope: UUID().uuidString)
        try backend.setData(try jsonData("from-environment"), forKey: "environment-key")
        let recorder = SecureStorageRecorder<String>()
        let host = SecureStorageHost(rootView:
            EnvironmentSecureStorageProbeView(recorder: recorder)
                .defaultSecureStorage(backend)
        )
        _ = host

        try await waitUntil { recorder.values.last == "from-environment" }
    }

    @Test func explicitBackendWinsOverEnvironment() async throws {
        let explicitBackend = InMemorySecureStorageBackend(scope: UUID().uuidString)
        let environmentBackend = InMemorySecureStorageBackend(scope: UUID().uuidString)
        try explicitBackend.setData(try jsonData("explicit"), forKey: "winner")
        try environmentBackend.setData(try jsonData("environment"), forKey: "winner")
        let recorder = SecureStorageRecorder<String>()
        let host = SecureStorageHost(rootView:
            SecureStorageProbeView(
                key: "winner",
                defaultValue: "default",
                backend: explicitBackend,
                recorder: recorder
            )
            .defaultSecureStorage(environmentBackend)
        )
        _ = host

        try await waitUntil { recorder.values.last == "explicit" }

        try environmentBackend.setData(try jsonData("environment-updated"), forKey: "winner")
        try await Task.sleep(for: .milliseconds(50))
        #expect(recorder.values.last == "explicit")

        try explicitBackend.setData(try jsonData("explicit-updated"), forKey: "winner")
        try await waitUntil { recorder.values.last == "explicit-updated" }
    }

    @Test func previewPathPersistsAcrossFreshWrapperInstances() {
        let backend = SystemSecureStorageBackend(
            namespace: "preview-\(UUID().uuidString)",
            resolver: SecureStorageSystemResolver(isPreview: { true })
        )
        let first = SecureStorage<String>("secret", defaultValue: "default", backend: backend)
        first.wrappedValue = "persisted"

        let second = SecureStorage<String>("secret", defaultValue: "default", backend: backend)
        #expect(second.wrappedValue == "persisted")
    }

    @Test func previewPathInvalidatesHostedViewOnExternalWrite() async throws {
        let backend = SystemSecureStorageBackend(
            namespace: "preview-live-\(UUID().uuidString)",
            resolver: SecureStorageSystemResolver(isPreview: { true })
        )
        let recorder = SecureStorageRecorder<String>()
        let host = SecureStorageHost(rootView: SecureStorageProbeView(
            key: "preview-key",
            defaultValue: "default",
            backend: backend,
            recorder: recorder
        ))
        _ = host

        try await waitUntil { recorder.values == ["default"] }

        try backend.setData(try jsonData("preview-updated"), forKey: "preview-key")
        try await waitUntil { recorder.values.last == "preview-updated" }
    }

    @Test func secureStoragePropertyWrappersCompileForRequestedSyntax() {
        let backend = InMemorySecureStorageBackend(scope: UUID().uuidString)
        let scene = SceneSecureStorageCompileScene()
        _ = scene
        let storage = SecureStorage<String>("compile", defaultValue: "value", backend: backend)
        #expect(storage.wrappedValue == "value")
    }
}
#endif
