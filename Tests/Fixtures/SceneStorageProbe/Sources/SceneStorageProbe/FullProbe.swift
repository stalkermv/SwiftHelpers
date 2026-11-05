import Foundation
import SwiftUI
import SwiftStorage
#if os(macOS)
import AppKit
#endif

struct FullProbe: View {
    @State private var stage = 0
    let scene: Int

    var body: some View {
        Group {
            if scene == 2 { MultipleScenesProbe(scene: 2, done: {}) }
            else if stage == 0 { FailureProbe { stage = 1 } }
            else if stage == 1 { LifecycleRoot { stage = 2 } }
            else if stage == 2 { DynamicKeyRoot { stage = 3 } }
            else if stage == 3 { MultipleScenesProbe(scene: 0, done: { stage = 4 }) }
            else {
                #if os(macOS)
                NestedHostProbe(done: finish)
                #else
                Text("Complete").task { finish() }
                #endif
            }
        }.frame(minWidth: 300, minHeight: 200)
    }

    func finish() {
        let e = Evidence.shared
        e.emit("complete", ["failures": e.failures, "nativeFailures": e.nativeFailures])
        #if os(macOS)
        NSApplication.shared.terminate(nil)
        #endif
    }
}

@MainActor final class SceneEndpoints {
    static let shared = SceneEndpoints()
    var endpoints: [Int: (id: UUID, native: Binding<Data>, value: Binding<Int>)] = [:]
}

struct MultipleScenesProbe: View {
    @Environment(\.openWindow) private var openWindow
    @SceneStorage("probe.multiscene") private var native = Data()
    @SceneStorage.Codable("probe.multiscene") private var value = -1
    @State private var session = UUID()
    let scene: Int
    let done: () -> Void

    var body: some View {
        Text("Independent scene \(scene)").task { await run() }
    }

    func run() async {
        let registry = SceneEndpoints.shared
        registry.endpoints[scene] = (session, $native, $value)
        guard scene == 0 else { return }
        openWindow(value: 2)
        for _ in 0..<80 {
            if registry.endpoints[2] != nil { break }
            try? await Task.sleep(for: .milliseconds(100))
        }
        let e = Evidence.shared
        guard let a = registry.endpoints[0], let b = registry.endpoints[2] else {
            e.check("scenes.two-real-windows", false)
            e.emit("unknown", ["criterion": "C5", "reason": "second WindowGroup scene did not register"])
            done()
            return
        }
        e.check("scenes.two-real-windows", a.id != b.id)
        a.value.wrappedValue = 101
        b.value.wrappedValue = 202
        e.check("scenes.distinct-native-bytes", a.native.wrappedValue == Data("101".utf8) && b.native.wrappedValue == Data("202".utf8), native: true)
        e.check("scenes.wrapper-isolation", a.value.wrappedValue == 101 && b.value.wrappedValue == 202)
        a.native.wrappedValue = Data("303".utf8)
        e.check("scenes.native-write-isolation", a.value.wrappedValue == 303 && b.value.wrappedValue == 202)
        b.value.wrappedValue = 404
        e.check("scenes.peer-write-isolation", a.value.wrappedValue == 303 && b.value.wrappedValue == 404)
        done()
    }
}
