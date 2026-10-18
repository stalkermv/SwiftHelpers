import Foundation
import SwiftUI
import SwiftStorage
#if os(macOS)
import AppKit

struct NestedHostProbe: NSViewRepresentable {
    let done: () -> Void
    func makeNSView(context: Context) -> NSHostingView<NestedContent> {
        NSHostingView(rootView: NestedContent(done: done))
    }
    func updateNSView(_ nsView: NSHostingView<NestedContent>, context: Context) {}
}

struct NestedContent: View {
    @SceneStorage("probe.nested") private var native = Data()
    @SceneStorage.Codable("probe.nested") private var value = -1
    let done: () -> Void

    var body: some View {
        Text("Nested hosting control").task {
            try? await Task.sleep(for: .milliseconds(100))
            native = Data("9".utf8)
            let expected = (try? JSONDecoder().decode(Int.self, from: native)) ?? -1
            Evidence.shared.check("nested.native-value-parity", value == expected)
            Evidence.shared.emit("nested-host", ["native": native.base64EncodedString(), "value": value])
            done()
        }
    }
}
#endif

struct RestorationProbe: View {
    @SceneStorage("probe.restoration") private var native = Data()
    @SceneStorage.Codable("probe.restoration") private var value = -1

    var body: some View {
        Text("Restoration parity").task {
            try? await Task.sleep(for: .milliseconds(200))
            let args = ProcessInfo.processInfo.arguments
            let seed = args.contains("seed")
            if seed { native = Data("73".utf8) }
            let expected = (try? JSONDecoder().decode(Int.self, from: native)) ?? -1
            Evidence.shared.check(seed ? "restoration.seed-parity" : "restoration.relaunch-parity", value == expected)
            Evidence.shared.emit("restoration", ["phase": seed ? "seed" : "read", "native": native.base64EncodedString(),
                                                   "restored": !seed && expected == 73,
                                                   "branch": seed ? "SEEDED" : (expected == 73 ? "OBSERVED" : "UNOBSERVED")])
            // Give SwiftUI a normal run-loop interval; this is not a durability promise.
            try? await Task.sleep(for: .milliseconds(500))
            Evidence.shared.emit("complete", ["failures": Evidence.shared.failures, "nativeFailures": Evidence.shared.nativeFailures])
            #if os(macOS)
            NSApplication.shared.terminate(nil)
            #endif
        }
    }
}
