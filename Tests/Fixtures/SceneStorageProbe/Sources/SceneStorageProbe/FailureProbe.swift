import Foundation
import SwiftUI
import SwiftStorage

enum ProbeFailure: Error { case privatePayloadMarker }

struct Fragile: Codable {
    let n: Int
    init(_ n: Int) { self.n = n }
    init(from decoder: Decoder) throws { n = try decoder.singleValueContainer().decode(Int.self) }
    func encode(to encoder: Encoder) throws {
        if n == -99 { DefaultEncodeCount.shared.increment() }
        if n < 0 { throw ProbeFailure.privatePayloadMarker }
        var container = encoder.singleValueContainer()
        try container.encode(n)
    }
}

struct RejectDecode: Codable {
    init() {}
    init(from decoder: Decoder) throws { throw ProbeFailure.privatePayloadMarker }
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(42)
    }
}

enum Choice: String, Codable { case first, second }

struct FailureProbe: View {
    @SceneStorage("probe.absence-control") private var absenceMarker = Data("sentinel".utf8)
    @SceneStorage("probe.absence-control") private var emptyControl = Data()
    @SceneStorage("probe.no-init-write") private var initMarker = Data("sentinel".utf8)
    @SceneStorage.Codable("probe.no-init-write") private var untouched = -7
    @SceneStorage("probe.failure") private var bytes = Data()
    @SceneStorage.Codable("probe.failure") private var fragile = Fragile(-99)
    @SceneStorage("probe.optional") private var optionalBytes = Data()
    @SceneStorage.Codable("probe.optional") private var optional: Int? = 5
    @SceneStorage("probe.reject") private var rejectBytes = Data()
    @SceneStorage.Codable("probe.reject") private var reject = RejectDecode()
    @SceneStorage.Codable("probe.enum") private var choice = Choice.first
    @SceneStorage.Codable("probe.collection") private var collection = [1, 2]
    @SceneStorage.Codable("probe.scalar") private var scalar = "default"
    let done: () -> Void

    var body: some View {
        Text("Failure and format probes").task { await run(); done() }
    }

    func run() async {
        await pause()
        let e = Evidence.shared
        // Native Data readers share the initial location/default. A visible marker
        // lets the control prove that an explicit empty write would be observable.
        e.check("native-default-control.initial-marker", absenceMarker == Data("sentinel".utf8), native: true,
                values: ["first": absenceMarker.base64EncodedString(), "second": emptyControl.base64EncodedString()])
        emptyControl = Data()
        await pause()
        e.check("absence-control.explicit-empty-replaces-marker", absenceMarker.isEmpty && emptyControl.isEmpty, native: true)
        _ = untouched
        e.check("initialization-and-fallback.no-empty-write", untouched == -7 && initMarker == Data("sentinel".utf8))
        e.check("default.encoder-never-called", DefaultEncodeCount.shared.value == 0)
        e.check("missing.default-readable-empty-native", bytes.isEmpty && fragile.n == -99 && bytes.isEmpty)
        bytes = Data("4".utf8)
        await pause()
        e.check("valid.native-control", bytes == Data("4".utf8), native: true)
        e.check("valid.before-corruption", fragile.n == 4)
        for raw in ["", "broken", "{}"] {
            let injected = Data(raw.utf8)
            bytes = injected
            await pause()
            e.check("corrupt.fallback.\(raw)", fragile.n == -99 && bytes == injected)
        }
        bytes = Data("8".utf8)
        await pause()
        e.check("corrupt.recovery", fragile.n == 8)
        fragile = Fragile(-1)
        e.check("failed-property-write.keeps-bytes", bytes == Data("8".utf8) && fragile.n == 8)
        $fragile.wrappedValue = Fragile(-2)
        e.check("failed-binding-write.keeps-bytes", bytes == Data("8".utf8) && fragile.n == 8)
        reject = RejectDecode()
        await pause()
        e.check("encode-success.accepted", rejectBytes == Data("42".utf8))
        _ = reject
        e.check("decode-failure.no-rollback", rejectBytes == Data("42".utf8))
        e.check("optional.missing-nonnil-default", optional == 5 && optionalBytes.isEmpty)
        optional = nil
        await pause()
        e.check("optional.explicit-null", optional == nil && optionalBytes == Data("null".utf8))
        $optional.wrappedValue = 7
        await pause()
        e.check("optional.binding-nonnil", optional == 7 && optionalBytes == Data("7".utf8))
        choice = .second
        $collection.wrappedValue = [3, 4, 5]
        scalar = "updated"
        e.check("format.enum-collection-scalar", choice == .second && collection == [3, 4, 5] && scalar == "updated")
        bytes = Data("12".utf8) // Retained standard JSON, no version envelope.
        await pause()
        e.check("format.legacy-json", fragile.n == 12)
    }

    func pause() async { try? await Task.sleep(for: .milliseconds(150)) }
}

final class DefaultEncodeCount: @unchecked Sendable {
    static let shared = DefaultEncodeCount()
    private let lock = NSLock()
    private var count = 0
    func increment() { lock.withLock { count += 1 } }
    var value: Int { lock.withLock { count } }
}
