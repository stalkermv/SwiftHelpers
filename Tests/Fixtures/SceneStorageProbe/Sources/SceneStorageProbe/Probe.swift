import Foundation
import SwiftUI
import SwiftStorage
#if os(macOS)
import AppKit
#endif

struct Payload: Codable, Equatable { let n: Int }

@MainActor final class Evidence {
    static let shared = Evidence()
    var failures = 0
    var nativeFailures = 0
    var bodyCount = 0
    var beforeReset = 0
    var heldDynamic: Binding<CountedValue>?
    var heldNative: Binding<Data>?
    var dynamicBodies = 0
    let file: FileHandle

    init() {
        let args = ProcessInfo.processInfo.arguments
        let path = args[args.firstIndex(of: "--output")! + 1]
        FileManager.default.createFile(atPath: path, contents: nil)
        file = try! FileHandle(forWritingTo: URL(fileURLWithPath: path))
    }

    func emit(_ event: String, _ values: [String: Any] = [:]) {
        var record = values
        record["event"] = event
        let bytes = try! JSONSerialization.data(withJSONObject: record, options: [.sortedKeys])
        file.write(bytes + Data([10]))
        file.synchronizeFile()
    }

    func check(_ name: String, _ pass: Bool, native: Bool = false, values: [String: Any] = [:]) {
        if !pass { failures += 1; if native { nativeFailures += 1 } }
        emit("check", values.merging(["name": name, "pass": pass, "nativeControl": native]) { _, b in b })
    }
}

struct PeerProbe: View {
    @SceneStorage("probe.peer") private var native = Data()
    @SceneStorage("probe.peer") private var nativePeer = Data()
    @SceneStorage.Codable("probe.peer") private var a = Payload(n: -1)
    @SceneStorage.Codable("probe.peer") private var b = Payload(n: -1)

    var body: some View {
        Text("Scene storage probe")
            .frame(minWidth: 300, minHeight: 160)
            .onChange(of: native) { _, bytes in
                if (try? JSONDecoder().decode(Payload.self, from: bytes).n) == 3 {
                    native = try! JSONEncoder().encode(Payload(n: 4))
                }
            }
            .task { await run() }
    }

    func observe(_ name: String, expected: Int, held: Binding<Payload>) {
        let decoded = (try? JSONDecoder().decode(Payload.self, from: native))?.n
        Evidence.shared.check(name + ".native", decoded == expected && native == nativePeer, native: true)
        Evidence.shared.check(name + ".wrapper", a.n == expected && b.n == expected && held.wrappedValue.n == expected,
                              values: ["a": a.n, "b": b.n, "held": held.wrappedValue.n, "expected": expected])
    }

    func run() async {
        try? await Task.sleep(for: .milliseconds(200))
        let held = $a
        native = try! JSONEncoder().encode(Payload(n: 0))
        observe("seed", expected: 0, held: held)
        a = Payload(n: 1)
        observe("first-write", expected: 1, held: held)
        b = Payload(n: 2)
        observe("peer-write", expected: 2, held: held)
        held.wrappedValue = Payload(n: 1)
        observe("held-ABA", expected: 1, held: held)
        native = try! JSONEncoder().encode(Payload(n: 3))
        observe("native-write", expected: 3, held: held)
        try? await Task.sleep(for: .milliseconds(200))
        observe("after-body-onChange", expected: 4, held: held)
        for step in 100..<120 {
            if step.isMultiple(of: 2) { a = Payload(n: step) }
            else { b = Payload(n: step) }
            observe("alternating-\(step)", expected: step, held: held)
        }
        Evidence.shared.emit("complete", ["failures": Evidence.shared.failures,
                                           "nativeFailures": Evidence.shared.nativeFailures])
        #if os(macOS)
        NSApplication.shared.terminate(nil)
        #endif
    }
}

@main struct SceneStorageProbeApp: App {
    var body: some Scene {
        WindowGroup(for: Int.self) { scene in
            if ProcessInfo.processInfo.arguments.contains("restoration") {
                RestorationProbe()
            } else if ProcessInfo.processInfo.arguments.contains("full") {
                FullProbe(scene: scene.wrappedValue ?? 0)
            } else { PeerProbe() }
        } defaultValue: { 0 }
    }
}
