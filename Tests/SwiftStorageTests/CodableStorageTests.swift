//
//  CodableStorageTests.swift
//  SwiftHelpers
//
//  Created by Valeriy Malishevskyi on 21.04.2026.
//

#if canImport(SwiftUI)
import Foundation
import SwiftUI
import Testing
@testable import SwiftStorage

private struct Payload: Swift.Codable, Equatable {
    var value: String
}

private struct AppPayloadStorageKey: AppStorageKey {
    static let defaultValue = Payload(value: "app-key-default")
}

private extension AppStorageKey where Self == AppPayloadStorageKey {
    static var appPayload: Self { .init() }
}

private struct SceneDotPayloadStorageKey: SceneStorageKey {
    static let defaultValue = Payload(value: "scene-dot-default")
}

private extension SceneStorageKey where Self == SceneDotPayloadStorageKey {
    static var scenePayload: Self { .init() }
}

private struct SceneKeyPathPayloadStorageKey: SceneStorageKey {
    static let defaultValue = Payload(value: "scene-keypath-default")
}

private extension SceneStorageKeys {
    var scenePathPayload: SceneKeyPathPayloadStorageKey { .init() }
}

private enum TestStores {
    static let suiteName = "SwiftHelpers.CodableStorageTests"

    static func appStorage() -> UserDefaults {
        UserDefaults(suiteName: suiteName)!
    }
}

private struct AppStorageStringCodableView: View {
    @AppStorage.Codable("app-string-payload", store: TestStores.appStorage())
    var payload = Payload(value: "app-string-default")

    var binding: Binding<Payload> { $payload }

    var body: some View {
        Text(payload.value)
    }
}

private struct AppStorageTypedCodableView: View {
    @AppStorage.Codable(.appPayload, store: TestStores.appStorage())
    var payload

    var binding: Binding<Payload> { $payload }

    var body: some View {
        Text(payload.value)
    }
}

private struct AppStorageOptionalCodableView: View {
    @AppStorage.Codable("app-optional-payload", store: TestStores.appStorage())
    var payload: Payload?

    var body: some View {
        Text(payload?.value ?? "nil")
    }
}

private struct SceneStorageStringCodableView: View {
    @SceneStorage.Codable("scene-string-payload")
    var payload = Payload(value: "scene-string-default")

    var binding: Binding<Payload> { $payload }

    var body: some View {
        Text(payload.value)
    }
}

private struct SceneStorageTypedCodableView: View {
    @SceneStorage.Codable(.scenePayload)
    var payload

    var binding: Binding<Payload> { $payload }

    var body: some View {
        Text(payload.value)
    }
}

private struct SceneStorageKeyPathCodableView: View {
    @SceneStorage.Codable(\.scenePathPayload)
    var payload

    var binding: Binding<Payload> { $payload }

    var body: some View {
        Text(payload.value)
    }
}

private struct SceneStorageOptionalCodableView: View {
    @SceneStorage.Codable("scene-optional-payload")
    var payload: Payload?

    var body: some View {
        Text(payload?.value ?? "nil")
    }
}

@MainActor
struct CodableStorageTests {
    @Test func codableAppStorageUsesDefaultValue() {
        let suiteName = "SwiftHelpers.CodableAppStorage.default.\(UUID().uuidString)"
        let store = UserDefaults(suiteName: suiteName)!
        defer { store.removePersistentDomain(forName: suiteName) }

        let defaultValue = Payload(value: "default")
        let storage = CodableAppStorage<Payload>(
            wrappedValue: defaultValue,
            "payload",
            store: store
        )

        #expect(storage.wrappedValue == defaultValue)
    }

    @Test func codableAppStorageRoundTripsCodableValue() {
        let suiteName = "SwiftHelpers.CodableAppStorage.roundTrip.\(UUID().uuidString)"
        let store = UserDefaults(suiteName: suiteName)!
        defer { store.removePersistentDomain(forName: suiteName) }

        let defaultValue = Payload(value: "default")
        let updatedValue = Payload(value: "updated")
        let storage = CodableAppStorage<Payload>(
            wrappedValue: defaultValue,
            "payload",
            store: store
        )

        storage.wrappedValue = updatedValue

        let storedPayload = store.data(forKey: "payload")
            .flatMap { try? JSONDecoder().decode(Payload.self, from: $0) }

        #expect(storage.wrappedValue == updatedValue)
        #expect(storedPayload == updatedValue)
    }

    @Test func codableAppStorageOptionalDefaultsToNil() {
        let suiteName = "SwiftHelpers.CodableAppStorage.optional.\(UUID().uuidString)"
        let store = UserDefaults(suiteName: suiteName)!
        defer { store.removePersistentDomain(forName: suiteName) }

        let storage = CodableAppStorage<Payload?>("payload", store: store)

        #expect(storage.wrappedValue == nil)
    }

    @Test func codableSceneStorageUsesDefaultValue() {
        let defaultValue = Payload(value: "default")
        let storage = CodableSceneStorage<Payload>(
            wrappedValue: defaultValue,
            "payload"
        )

        #expect(storage.wrappedValue == defaultValue)
    }

    @Test func codableSceneStorageRoundTripsCodableValue() {
        let defaultValue = Payload(value: "default")
        let updatedValue = Payload(value: "updated")
        let storage = CodableSceneStorage<Payload>(
            wrappedValue: defaultValue,
            "payload"
        )

        storage.wrappedValue = updatedValue

        #expect(storage.wrappedValue == updatedValue)
    }

    @Test func codableSceneStorageOptionalDefaultsToNil() {
        let storage = CodableSceneStorage<Payload?>("payload")

        #expect(storage.wrappedValue == nil)
    }

    @Test func codableStoragePropertyWrappersCompileForRequestedSyntax() {
        let store = TestStores.appStorage()
        store.removePersistentDomain(forName: TestStores.suiteName)

        #expect(AppStorageStringCodableView().binding.wrappedValue == Payload(value: "app-string-default"))
        #expect(AppStorageTypedCodableView().binding.wrappedValue == AppPayloadStorageKey.defaultValue)
        #expect(AppStorageOptionalCodableView().payload == nil)
        #expect(SceneStorageStringCodableView().binding.wrappedValue == Payload(value: "scene-string-default"))
        #expect(SceneStorageTypedCodableView().binding.wrappedValue == SceneDotPayloadStorageKey.defaultValue)
        #expect(SceneStorageKeyPathCodableView().binding.wrappedValue == SceneKeyPathPayloadStorageKey.defaultValue)
        #expect(SceneStorageOptionalCodableView().payload == nil)
    }
}
#endif
