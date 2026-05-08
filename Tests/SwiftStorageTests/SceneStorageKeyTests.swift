//
//  SceneStorageKeyTests.swift
//  SwiftHelpers
//
//  Created by Valeriy Malishevskyi on 21.04.2026.
//

#if canImport(SwiftUI)
import SwiftUI
import Testing
@testable import SwiftStorage

private struct SampleStringSceneStorageKey: SceneStorageKey {
    static let defaultValue = "inbox"
}

private enum SampleSidebarSelection: String {
    case inbox
    case archive
}

private struct SampleEnumSceneStorageKey: SceneStorageKey {
    static let defaultValue: SampleSidebarSelection = .inbox
}

private struct SampleOptionalSceneStorageKey: SceneStorageKey {
    typealias Value = String?
}

private extension SceneStorageKeys {
    var testKey: SampleStringSceneStorageKey { .init() }
    var enumKey: SampleEnumSceneStorageKey { .init() }
    var optionalKey: SampleOptionalSceneStorageKey { .init() }
}

private struct PrimitiveInferenceView: View {
    @SceneStorage(\.testKey) private var value

    var currentValue: String { value }

    var body: some View {
        Text(value)
    }
}

private struct EnumInferenceView: View {
    @SceneStorage(\.enumKey) private var value

    var currentValue: SampleSidebarSelection { value }

    var body: some View {
        Text(value.rawValue)
    }
}

private struct OptionalInferenceView: View {
    @SceneStorage(\.optionalKey) private var value

    var currentValue: String? { value }

    var body: some View {
        Text(value ?? "nil")
    }
}

@MainActor
struct SceneStorageKeyTests {
    @Test func stringKeyUsesDefaultValue() {
        let storage = SceneStorage<String>(\.testKey)

        #expect(storage.wrappedValue == SampleStringSceneStorageKey.defaultValue)
    }

    @Test func keyNameMatchesTypeName() {
        #expect(SampleStringSceneStorageKey.key == "SampleStringSceneStorageKey")
    }

    @Test func rawRepresentableKeyUsesDefaultValue() {
        let storage = SceneStorage<SampleSidebarSelection>(\.enumKey)

        #expect(storage.wrappedValue == .inbox)
    }

    @Test func optionalKeyDefaultsToNil() {
        let storage = SceneStorage<String?>(\.optionalKey)

        #expect(storage.wrappedValue == nil)
    }

    @Test func sceneStorageTypeInferenceWorksInViews() {
        #expect(PrimitiveInferenceView().currentValue == SampleStringSceneStorageKey.defaultValue)
        #expect(EnumInferenceView().currentValue == .inbox)
        #expect(OptionalInferenceView().currentValue == nil)
    }
}
#endif
