import Foundation
import SwiftUI
import SwiftStorage

final class DecodeCount: @unchecked Sendable {
    static let shared = DecodeCount()
    private let lock = NSLock()
    private var count = 0
    func increment() { lock.withLock { count += 1 } }
    var value: Int { lock.withLock { count } }
}

struct CountedValue: Codable {
    let n: Int
    init(_ n: Int) { self.n = n }
    init(from decoder: Decoder) throws {
        DecodeCount.shared.increment()
        n = try decoder.singleValueContainer().decode(Int.self)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(n)
    }
}

struct LifecycleRoot: View {
    @SceneStorage("probe.lifecycle") private var native = Data()
    @State private var inserted = false
    @State private var identity = 0
    @State private var pulse = 0
    let done: () -> Void

    var body: some View {
        Group {
            if inserted {
                LifecycleReader(identity: identity, pulse: $pulse, reset: { identity += 1 }, done: done)
                    .id(identity)
            } else { Text("Preseeding") }
        }.task {
            native = Data("17".utf8)
            inserted = true
        }
    }
}

struct LifecycleReader: View {
    @SceneStorage("probe.lifecycle") private var native = Data()
    @SceneStorage.Codable("probe.lifecycle") private var value: CountedValue?
    @State private var localPulse = 0
    let identity: Int
    @Binding var pulse: Int
    let reset: () -> Void
    let done: () -> Void

    var body: some View {
        let _ = recordBody()
        Text("Lifecycle \(localPulse) \(pulse)").task { await run() }
    }

    func recordBody() {
        _ = value
        Evidence.shared.bodyCount += 1
        Evidence.shared.emit("body", ["identity": identity, "decodes": DecodeCount.shared.value])
    }

    func run() async {
        await pause() // Let native preseed invalidations settle before the quiet-window measurement.
        let e = Evidence.shared
        e.check("rehydration.preseed.\(identity)", value?.n == 17 && native == Data("17".utf8))
        let before = DecodeCount.shared.value
        if identity == 1 {
            e.check("identity.new-cache-decodes", before > e.beforeReset)
            done()
            return
        }
        let held = $value
        let bodies = e.bodyCount
        for _ in 0..<1000 { _ = value; _ = held.wrappedValue }
        await pause()
        e.check("memo.2000-reads-no-decode", DecodeCount.shared.value == before)
        e.check("memo.cache-reads-no-body", e.bodyCount == bodies)
        for step in 1...3 { localPulse = step; await pause() }
        for step in 1...3 { pulse = step; await pause() }
        e.check("memo.six-body-updates-observed", e.bodyCount >= bodies + 6)
        e.check("memo.unchanged-body-no-decode", DecodeCount.shared.value == before)
        e.beforeReset = before
        reset()
    }

    func pause() async { try? await Task.sleep(for: .milliseconds(120)) }
}

struct DynamicKeyRoot: View {
    @State private var key = "probe.dynamic.a"
    @State private var fallback = 1
    @State private var phase = 0
    let done: () -> Void

    var body: some View {
        DynamicKeyReader(key: key, fallback: fallback, phase: phase) {
            if phase == 0 { fallback = 2; phase = 1 }
            else if phase == 1 { key = "probe.dynamic.b"; phase = 2 }
            else { done() }
        }
    }
}

struct DynamicKeyReader: View {
    @SceneStorage private var native: Data
    @SceneStorage.Codable private var value: CountedValue
    let phase: Int
    let fallback: Int
    let next: () -> Void

    init(key: String, fallback: Int, phase: Int, next: @escaping () -> Void) {
        self._native = SceneStorage(wrappedValue: Data(), key)
        self._value = CodableSceneStorage(wrappedValue: CountedValue(fallback), key)
        self.phase = phase
        self.fallback = fallback
        self.next = next
    }

    var body: some View {
        let _ = recordBody()
        Text("Dynamic configuration \(phase)").task(id: phase) {
            let e = Evidence.shared
            if phase < 2 {
                e.check("default.current.\(phase)", native.isEmpty && value.n == fallback)
                if phase == 1 {
                    native = Data("31".utf8)
                    e.heldDynamic = $value
                    e.heldNative = $native
                }
            } else {
                // SwiftUI may retain the original location for runtime key changes.
                let expected = (try? JSONDecoder().decode(Int.self, from: native)) ?? fallback
                e.check("key.native-location-parity", value.n == expected)
                native = Data("32".utf8)
                let current = (try? JSONDecoder().decode(Int.self, from: native)) ?? fallback
                e.check("key.read-after-write-parity", value.n == current)
                let old = e.heldNative!.wrappedValue
                e.check("key.held-binding-location", e.heldDynamic!.wrappedValue.n == (try? JSONDecoder().decode(Int.self, from: old)))
                e.emit("key-change-observation", ["current": value.n, "old": e.heldDynamic!.wrappedValue.n])
                try? await Task.sleep(for: .milliseconds(150))
                let bodies = e.dynamicBodies
                let decodes = DecodeCount.shared.value
                let nativeBefore = native
                let oldNativeBefore = e.heldNative!.wrappedValue
                // Old binding uses key A; current wrapper uses key B. Alternating
                // successful reads refills the one-entry cache without native writes.
                for _ in 0..<100 { _ = e.heldDynamic!.wrappedValue; _ = value }
                try? await Task.sleep(for: .milliseconds(150))
                // The first old-key read may hit the already primed entry; the
                // remaining199 reads alternate keys and must refill the cache.
                e.check("memo.cache-refill-performs-decode", DecodeCount.shared.value >= decodes + 199,
                        values: ["before": decodes, "after": DecodeCount.shared.value])
                e.check("memo.cache-refill-keeps-native-bytes", native == nativeBefore && e.heldNative!.wrappedValue == oldNativeBefore)
                e.check("memo.cache-refill-no-body", e.dynamicBodies == bodies)
            }
            next()
        }
    }

    func recordBody() { Evidence.shared.dynamicBodies += 1 }
}
