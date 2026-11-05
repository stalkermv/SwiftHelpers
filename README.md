# SwiftHelpers

[![Swift](https://github.com/stalkermv/SwiftHelpers/actions/workflows/tests.yml/badge.svg)](https://github.com/stalkermv/SwiftHelpers/actions/workflows/tests.yml)

SwiftHelpers is a comprehensive collection of Swift extensions and utilities designed to simplify common tasks and improve code readability in your Swift projects. The library is organized into focused modules covering foundation extensions, secure storage, Combine utilities, and development tools.

## Modules

### SwiftHelpers
The main module that combines FoundationExtensions and CombineExtensions for convenience.

### FoundationExtensions
Core Swift and Foundation framework extensions:
- **Array extensions** for safe subscripting, sorting, filtering, and mutations
- **Sequence extensions** for unique filtering and transformations
- **Optional extensions** for safe unwrapping with detailed error handling
- **Comparable extensions** for value clamping
- **Date extensions** for easy date manipulation and ISO8601 parsing
- **Bundle extensions** for app version and build information
- **Calendar extensions** for current date handling

### SwiftStorage
Secure storage solution with reactive updates:
- **SecureStorage** `DynamicProperty` for SwiftUI with automatic observation
- **SecureStorageBackend** protocol for custom backend implementations
- **SystemSecureStorageBackend** for automatic preview/file vs keychain selection
- **KeychainSecureStorageBackend** for secure keychain-backed storage
- **FileSecureStorageBackend** for file-backed storage in temporary directories
- **InMemorySecureStorageBackend** for isolated in-memory storage
- **SecureStorageKey** protocol for type-safe storage keys
- **AppStorageKey** protocol for enhanced AppStorage usage
- **SceneStorageKey** protocol for enhanced SceneStorage usage
- **AppStorage.Codable / SceneStorage.Codable** for Data-backed Codable values

### CombineExtensions
Combine framework utilities:
- **TaskFuture** for bridging async/await with Combine publishers

### Development
Development and debugging utilities:
- **String extensions** for Lorem ipsum generation
- **URL extensions** for random image generation
- **Binding extensions** for debug printing
- **View extensions** for software keyboard enforcement

## Installation

### Swift Package Manager

Add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/stalkermv/SwiftHelpers", from: "1.0.0")
```

Then, add the desired modules to your target's dependencies:

```swift
.target(name: "YourTarget", dependencies: [
    "SwiftHelpers",      // Main module (includes FoundationExtensions + CombineExtensions)
    "SwiftStorage",      // Secure storage functionality
    "Development"        // Development utilities
])
```

## Usage

### Foundation Extensions

```swift
import FoundationExtensions

// Safe array subscripting
let numbers = [1, 2, 3, 4, 5]
let safeValue = numbers[safeIndex: 10] // Returns nil instead of crashing

// Array sorting by key path
struct Person {
    let name: String
    let age: Int
}
let people = [Person(name: "Alice", age: 30), Person(name: "Bob", age: 25)]
let sortedByName = people.sorted(keyPath: \.name)
let sortedByAge = people.sorted(keyPath: \.age, ascending: false)

// Value clamping
let clampedValue = 15.clamped(to: 10...20) // Returns 15
let clampedHigh = 25.clamped(to: 10...20)  // Returns 20

// Safe optional unwrapping with detailed errors
let optionalValue: String? = nil
do {
    let value = try optionalValue.unwrapped()
} catch {
    print("Failed to unwrap: \(error)")
}

// Unique filtering
let numbers = [1, 2, 2, 3, 3, 3, 4]
let uniqueNumbers = numbers.unique() // [1, 2, 3, 4]
let uniqueByProperty = people.unique(by: \.age)
```

### Secure Storage

```swift
import SwiftStorage
import SwiftUI

// SystemSecureStorageBackend is the default.
// In previews it uses a temporary file store, and on device it prefers Keychain.
struct ContentView: View {
    @SecureStorage("user_preference", defaultValue: "default")
    private var userPreference: String

    var body: some View {
        VStack {
            Text("Current preference: \(userPreference)")
            Button("Update Preference") {
                userPreference = "updated_\(Date().timeIntervalSince1970)"
            }
            if let error = _userPreference.error {
                Text("Error: \(error.localizedDescription)")
            }
        }
    }
}

struct UserSettingKey: SecureStorageKey {
    static let defaultValue = "default"
    init() {}
}

struct SettingsView: View {
    @SecureStorage(UserSettingKey())
    private var userSetting: String

    var body: some View {
        Text("Setting: \(userSetting)")
    }
}

struct PreviewRoot: View {
    private let backend = InMemorySecureStorageBackend(scope: "preview")

    var body: some View {
        ContentView()
            .defaultSecureStorage(backend)
    }
}

struct ExplicitBackendView: View {
    @SecureStorage("api_token", defaultValue: "", backend: InMemorySecureStorageBackend(scope: "demo"))
    private var token: String

    var body: some View {
        Text(token.isEmpty ? "Missing token" : "Token is stored")
    }
}

enum SidebarSelection: String {
    case inbox
    case archive
}

struct SidebarSelectionSceneStorageKey: SceneStorageKey {
    static let defaultValue: SidebarSelection = .inbox
}

extension SceneStorageKeys {
    var sidebarSelection: SidebarSelectionSceneStorageKey { .init() }
}

struct SceneRootView: View {
    @SceneStorage(\.sidebarSelection) private var selection

    var body: some View {
        Text(selection.rawValue)
    }
}

struct ConversationState: Codable {
    var selectedID: String?
}

struct ConversationAppStorageKey: AppStorageKey {
    static let defaultValue = ConversationState(selectedID: nil)
}

extension AppStorageKey where Self == ConversationAppStorageKey {
    static var conversationState: Self { .init() }
}

struct ConversationSceneStorageKey: SceneStorageKey {
    static let defaultValue = ConversationState(selectedID: nil)
}

extension SceneStorageKey where Self == ConversationSceneStorageKey {
    static var conversationState: Self { .init() }
}

extension SceneStorageKeys {
    var conversationSceneState: ConversationSceneStorageKey { .init() }
}

struct CodableStorageView: View {
    @AppStorage.Codable(.conversationState) private var appState
    @SceneStorage.Codable(.conversationState) private var sceneState
    @SceneStorage.Codable(\.conversationSceneState) private var keyPathSceneState

    var body: some View {
        Text(appState.selectedID ?? sceneState.selectedID ?? keyPathSceneState.selectedID ?? "none")
    }
}
```

`SceneStorage.Codable` uses native scene storage without a setup modifier. Its
value and binding accessors run on the main actor; initialization does not require
a main-actor context. Values only need `Codable`, including reference types that
are not `Sendable` or `Equatable`.

Each read consults the current native `Data`. Successful decoding is reused while
the key and complete bytes match, including across view updates with the same
identity. A new view identity creates a fresh cache. Missing, empty, malformed or
incompatible JSON returns the current declared default without rewriting bytes.
An Optional `nil` is stored as JSON `null`, so it remains distinct from missing
data even with a nonnil default.

Writes use standard `JSONEncoder`/`JSONDecoder` strategies. A successful assignment
clears the local decoded cache even when the encoded bytes are unchanged. An
encoding failure leaves both the stored bytes and cache unchanged and emits a
fixed system diagnostic without the key, payload or error text. If encoding
succeeds but decoding later fails, the bytes remain stored and reads return the
default. Defaults are never encoded during initialization. Bindings forward their
transaction to the native binding.

A cached reference value may be the same object on subsequent reads. Mutating it
without assigning through the property does not persist it. Reference defaults
are returned directly without cloning, and custom decoding side effects do not
repeat on cache hits.

Typed keys retain their existing type-name identity: renaming a key type can
change its storage key, and equal type names can collide. Use a string key when
explicit stable identity is required. Changing a key at an existing view identity
follows native `SceneStorage` location behavior; recreate that identity when a
new storage location is required. A previously captured binding keeps its native
location and default snapshot.

Use this storage for small UI state. Scene isolation, restoration timing and
durability are provided by SwiftUI. Hosting configurations that do not update
native `SceneStorage` have the same limitation here; the library adds no window
revision relay. `AppStorage.Codable` retains its existing behavior.

### Combine Extensions

```swift
import CombineExtensions
import Combine

// Bridge async/await with Combine
let future = TaskFuture<Int, Error> {
    try await Task.sleep(nanoseconds: 1_000_000_000)
    return 42
}

future
    .sink(
        receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Completed successfully")
            case .failure(let error):
                print("Failed with error: \(error)")
            }
        },
        receiveValue: { value in
            print("Received value: \(value)")
        }
    )
```

### Development Utilities

```swift
import Development

// Lorem ipsum generation
let sentence = String.randomSentence()
let paragraph = String.randomParagraph()
let lorem = String.randomLorem()

// Random image URLs
let imageURL = URL.randomImage(width: 300, height: 200)

// Debug binding printing
@State private var count = 0
var body: some View {
    Stepper("Count", value: $count.print("Counter"))
}
// Console output:
// {< GET} Counter: 0
// {> SET} Counter: 1
```

Contributing
------------

Contributions to SwiftHelpers are welcome! Feel free to submit a pull request with new features, improvements, or bug fixes. Please make sure to add documentation and unit tests for any changes you make.

License
-------

SwiftHelpers is released under the MIT License. See the [LICENSE](License) file for more information.
