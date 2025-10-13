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
- **SecureStorage** property wrapper for SwiftUI with automatic observation
- **KeychainSecureStorage** for secure keychain-based storage
- **InMemorySecureStorage** for in-memory storage with observation
- **DiskNonSecureStorage** for development/preview storage
- **SecureStorageKey** protocol for type-safe storage keys
- **AppStorageKey** protocol for enhanced AppStorage usage

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

// Basic secure storage with automatic observation
struct ContentView: View {
    @SecureStorage("user_preference", defaultValue: "default")
    var userPreference: String
    
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

// Type-safe storage with keys
enum UserSettings: SecureStorageKey {
    typealias Value = String
    static var defaultValue: String = "default"
}

struct SettingsView: View {
    @SecureStorage(UserSettings.self)
    var userSetting: String
    
    var body: some View {
        Text("Setting: \(userSetting)")
    }
}

// Custom storage service
struct ContentView: View {
    @SecureStorage("key", defaultValue: "default", store: InMemorySecureStorage.shared)
    var value: String
    
    var body: some View {
        Text(value)
    }
}
```

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
