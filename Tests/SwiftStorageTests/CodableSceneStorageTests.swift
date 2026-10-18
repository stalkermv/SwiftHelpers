#if canImport(SwiftUI)
import Foundation
import SwiftUI
import Testing
@testable import SwiftStorage

// Decodable is nonisolated. Only this lock-protected test counter is shared.
private final class DecodeCounter: @unchecked Sendable {
    static let shared = DecodeCounter()
    private let lock = NSLock()
    private var count = 0
    func increment() { lock.withLock { count += 1 } }
    func reset() { lock.withLock { count = 0 } }
    var value: Int { lock.withLock { count } }
}

private struct Counted: Codable {
    let n: Int
    init(from decoder: Decoder) throws {
        DecodeCounter.shared.increment()
        n = try decoder.singleValueContainer().decode(Int.self)
    }
}

private enum FixtureError: Error { case rejected }

private struct Rejecting: Codable {
    let n: Int
    init(n: Int) { self.n = n }
    init(from decoder: Decoder) throws { n = try decoder.singleValueContainer().decode(Int.self) }
    func encode(to encoder: Encoder) throws {
        if n < 0 { throw FixtureError.rejected }
        var container = encoder.singleValueContainer()
        try container.encode(n)
    }
}

private struct Normalized: Codable {
    let n: Int
    init(n: Int) { self.n = n }
    init(from decoder: Decoder) throws { n = abs(try decoder.singleValueContainer().decode(Int.self)) }
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(n)
    }
}

private struct Undecodable: Codable {
    init() {}
    init(from decoder: Decoder) throws { throw FixtureError.rejected }
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(7)
    }
}

private final class ReferenceValue: Codable {
    var n: Int
    init(_ n: Int) { self.n = n }
}

private struct Marker: TransactionKey { static let defaultValue = 0 }

@MainActor @Suite(.serialized)
struct CodableSceneStorageTests {
    @Test("Identical bytes reuse decoding across distinct Data allocations")
    func repeatedReads() throws {
        DecodeCounter.shared.reset()
        let cache = CodableSceneStorageCache<Counted>()
        for _ in 0..<1000 {
            #expect(try #require(cache.decode(Data("42".utf8), forKey: "a")).n == 42)
        }
        #expect(DecodeCounter.shared.value == 1)
    }

    @Test("Changed bytes, ABA and key changes each select the current snapshot")
    func changedBytesAndKeys() throws {
        DecodeCounter.shared.reset()
        let cache = CodableSceneStorageCache<Counted>()
        for (key, raw) in [("a", "1"), ("a", "2"), ("a", "1"), ("b", "1")] {
            #expect(try #require(cache.decode(Data(raw.utf8), forKey: key)).n == Int(raw))
        }
        #expect(DecodeCounter.shared.value == 4)
    }

    @Test("Malformed, schema-mismatched and empty bytes return the current fallback", arguments: ["", "broken", "{}"])
    func decodeFailure(raw: String) throws {
        let cache = CodableSceneStorageCache<Int>()
        #expect(cache.decode(Data("9".utf8), forKey: "a") == 9)
        #expect((cache.decode(Data(raw.utf8), forKey: "a") ?? 3) == 3)
        #expect((cache.decode(Data(raw.utf8), forKey: "a") ?? 4) == 4)
        #expect(cache.decode(Data("8".utf8), forKey: "a") == 8)
    }

    @Test("JSON null is a successful Optional nil, distinct from failure")
    func optionalNull() {
        let cache = CodableSceneStorageCache<Int?>()
        let null = cache.decode(Data("null".utf8), forKey: "a")
        #expect(null == .some(.none))
        #expect((null ?? 5) == nil)
        #expect((cache.decode(Data("null".utf8), forKey: "a") ?? 5) == nil)
        #expect((cache.decode(Data(), forKey: "a") ?? 5) == 5)
        #expect(cache.encode(nil) == Data("null".utf8))
    }

    @Test("A rejected binding write preserves the supplied bytes and decoded value")
    func rejectedWrite() {
        let cache = CodableSceneStorageCache<Rejecting>()
        var bytes = Data("4".utf8)
        let native = Binding(get: { bytes }, set: { bytes = $0 })
        let binding = cache.binding(to: native, key: "a", defaultValue: Rejecting(n: -2))
        #expect(binding.wrappedValue.n == 4)
        binding.wrappedValue = Rejecting(n: -1)
        #expect(bytes == Data("4".utf8))
        #expect(binding.wrappedValue.n == 4)
        #expect(cache.encode(Rejecting(n: -1)) == nil)
    }

    @Test("A throwing default can be read without encoding it")
    func throwingDefault() {
        let cache = CodableSceneStorageCache<Rejecting>()
        var bytes = Data()
        let native = Binding(get: { bytes }, set: { bytes = $0 })
        let binding = cache.binding(to: native, key: "a", defaultValue: Rejecting(n: -3))
        #expect(binding.wrappedValue.n == -3)
        #expect(bytes.isEmpty)
    }

    @Test("Accepted bytes are retained even when the decoder rejects them")
    func noDecodeRollback() {
        let cache = CodableSceneStorageCache<Undecodable>()
        var bytes = Data()
        let native = Binding(get: { bytes }, set: { bytes = $0 })
        let binding = cache.binding(to: native, key: "a", defaultValue: Undecodable())
        binding.wrappedValue = Undecodable()
        #expect(bytes == Data("7".utf8))
        _ = binding.wrappedValue
        #expect(cache.decode(bytes, forKey: "a") == nil)
        #expect(bytes == Data("7".utf8))
    }

    @Test("A binding setter does not seed the cache with an unnormalized value")
    func normalizedRead() {
        let cache = CodableSceneStorageCache<Normalized>()
        var bytes = Data()
        let native = Binding(get: { bytes }, set: { bytes = $0 })
        let binding = cache.binding(to: native, key: "a", defaultValue: Normalized(n: 0))
        binding.wrappedValue = Normalized(n: -7)
        #expect(bytes == Data("-7".utf8))
        #expect(binding.wrappedValue.n == 7)
    }

    @Test("Memoized reference identity and mutations do not imply persistence")
    func referenceIdentity() throws {
        let cache = CodableSceneStorageCache<ReferenceValue>()
        let bytes = Data("{\"n\":1}".utf8)
        let first = try #require(cache.decode(bytes, forKey: "a"))
        first.n = 2
        let cached = try #require(cache.decode(bytes, forKey: "a"))
        #expect(cached === first)
        #expect(cached.n == 2)
        let rebuilt = CodableSceneStorageCache<ReferenceValue>()
        #expect(try #require(rebuilt.decode(bytes, forKey: "a")).n == 1)
    }

    @Test("Reference defaults are returned directly and are not cloned")
    func referenceDefault() {
        let cache = CodableSceneStorageCache<ReferenceValue>()
        let fallback = ReferenceValue(1)
        let binding = cache.binding(to: .constant(Data()), key: "a", defaultValue: fallback)
        #expect(binding.wrappedValue === fallback)
        binding.wrappedValue.n = 2
        #expect(binding.wrappedValue.n == 2)
    }

    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    @Test("The production binding conversion forwards transaction markers and flags")
    func bindingTransaction() {
        var bytes = Data()
        var received = Transaction()
        let native = Binding(get: { bytes }, set: { value, transaction in bytes = value; received = transaction })
        var tx = Transaction()
        tx[Marker.self] = 731
        tx.disablesAnimations = true
        let cache = CodableSceneStorageCache<Int>()
        let converted = cache.binding(to: native, key: "a", defaultValue: 0)
        withTransaction(tx) {
            converted.transaction(tx).wrappedValue = 12
        }
        #expect(bytes == Data("12".utf8))
        #expect(received[Marker.self] == 731)
        #expect(received.disablesAnimations)
        let control = Binding<Int>(get: { 0 }, set: { native.wrappedValue = Data(String($0).utf8) })
        control.transaction(tx).wrappedValue = 13
        #expect(received[Marker.self] == 0)
        #expect(received.disablesAnimations == false)
        // Ambient-only writes must behave like the supplied native endpoint.
        withTransaction(tx) { native.wrappedValue = Data("21".utf8) }
        let ambientMarker = received[Marker.self]
        let ambientDisablesAnimations = received.disablesAnimations
        withTransaction(tx) { converted.wrappedValue = 22 }
        #expect(bytes == Data("22".utf8))
        #expect(received[Marker.self] == ambientMarker)
        #expect(received.disablesAnimations == ambientDisablesAnimations)
    }
}
#endif
