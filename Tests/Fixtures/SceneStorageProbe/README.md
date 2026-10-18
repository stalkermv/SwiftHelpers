# Installed SceneStorage regression fixture

This independent Swift package imports the actual local `SwiftStorage` product.
It does not copy the wrapper or require a library setup modifier. The fixture
requires macOS 14 or iOS 17; the library deployment floors are unchanged.

The root `swift test` command runs the library's unit tests. It does not build or
launch this nested executable package. Build it explicitly for API compile
coverage, or use the runner below for installed-scene assertions.

Run from the repository root with a fresh absolute evidence directory:

```sh
swift build --package-path Tests/Fixtures/SceneStorageProbe --scratch-path /tmp/scene-build-macos
Tests/Fixtures/SceneStorageProbe/run_probe.sh macos --evidence /tmp/scene-peer-macos
Tests/Fixtures/SceneStorageProbe/run_probe.sh ios --device <booted-iPad-UDID> --evidence /tmp/scene-peer-ios
Tests/Fixtures/SceneStorageProbe/run_probe.sh macos --suite full --evidence /tmp/scene-full-macos
Tests/Fixtures/SceneStorageProbe/run_probe.sh ios --device <booted-iPad-UDID> --suite full --evidence /tmp/scene-full-ios
Tests/Fixtures/SceneStorageProbe/run_probe.sh macos --suite restoration --evidence /tmp/scene-restore-macos
```

The default `peer-regression` suite compares two Codable readers, a retained
binding, native Data controls, ABA, onChange writes and 20 alternating writes.
Exit 0 means every named assertion passed. A build/launch failure or timeout is
an infrastructure failure, never a regression assertion result. The old wrapper
with a permanent local-write flag must fail wrapper assertions while native
controls stay green. Run the identical fixture against a source archive of that
baseline, preserving its production source and using separate evidence folders.

The `full` suite adds actual byte-preservation failures, Optional null/format,
preseeded rehydration, repeated reads, six body updates, identity reset,
runtime key/default changes, cache-refill quiet interval and two actual
WindowGroup scenes. Use iPad for the iOS multiscene test. macOS also compares
one nested NSHostingView to its native Data control. Key changes can retain the
original native storage location; the fixture asserts parity and logs it.

The `restoration` suite launches the same installed app twice. Relaunch parity
is asserted against native bytes; if the OS does not restore the seeded value,
the restored-value branch is explicitly `UNOBSERVED`. This does not assert
durability after termination. No simulator erase, shutdown, or toolchain install
is performed. Each run uses a unique bundle identifier and stops only its app.

Evidence includes exact commands/statuses, source hashes, OS/Swift versions,
raw JSONL and named assertions. Runtime waits are bounded to 30 seconds per
launch. Build artifacts remain in the requested evidence directory.
[APIForms.swift](Sources/SceneStorageProbe/APIForms.swift) is compiled as part of
the executable target and covers all four public forms, non-Sendable reference
values and initialization outside the main actor. Those declarations provide
compile coverage; they are not runtime assertions about uninstalled wrappers.
