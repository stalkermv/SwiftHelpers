# SwiftHelpers
[![Swift](https://github.com/stalkermv/SwiftHelpers/actions/workflows/tests.yml/badge.svg)](https://github.com/stalkermv/SwiftHelpers/actions/workflows/tests.yml)

[![Swift](https://github.com/stalkermv/SwiftHelpers/actions/workflows/tests.yml/badge.svg)](https://github.com/stalkermv/SwiftHelpers/actions/workflows/tests.yml)

SwiftHelpers is a collection of convenient Swift extensions and helper functions designed to simplify common tasks and improve code readability in your Swift projects. These utilities cover a wide range of functionalities, from working with arrays and strings to manipulating dates and handling optional values.

Features
--------

*   Array extensions for sorting, subscripting, and mutation
*   String extensions for regex evaluation and validation
*   Date extensions for easy date manipulation and formatting
*   Optional extensions for error handling and unwrapping
*   Codable extensions for easy JSON encoding and decoding
*   Sequence extensions for unique filtering and transformations
*   Bundle extensions for retrieving app version and build information
*   Comparable extensions for value clamping

Installation
------------

### Swift Package Manager

Add the following line to the dependencies in your `Package.swift` file:

swift

```swift
.package(url: "https://github.com/stalkermv/SwiftHelpers", from: "1.0.0")
```

Then, add `SwiftHelpers` to your target's dependencies:

swift

```swift
.target(name: "YourTarget", dependencies: ["SwiftHelpers"])
```

Usage
-----

After installing the library, simply import `SwiftHelpers` at the top of your Swift files and start using the provided extensions and helper functions.


```swift
import SwiftHelpers

// Example usage
let numbers = [1, 3, 2, 4]
let sortedNumbers = numbers.sorted { $0 < $1 }

let dateString = "2023-01-01T12:00:00Z"
let date = try? Date(iso8601: dateString)
```

#### Storage
The library defines two protocols for synchronous and asynchronous storage objects, respectively:

*   `Storage`: A synchronous storage object that defines a set of methods for saving, loading, and removing encoded objects from a storage object.
*   `AsyncStorage`: An asynchronous storage object that defines a set of methods for saving, loading, and removing encoded objects from a storage object asynchronously.

The `Storage` target provides two default implementations of `Storage`:

*   `KeychainStorage`: A synchronous storage object that uses the system keychain to store and retrieve data.
*   `UserDefaults`: A synchronous storage object that uses the `UserDefaults` system to store and retrieve data.

The library provides a property wrapper `StorableValue` that enables easy and safe storage of any `Codable` object. To use `StorableValue`, initialize it with the default value, a key, and a storage object.

```swift
import SwiftHelpers
import Storage

// Example usage of StorableValue with UserDefaults
@StorableValue(key: "exampleKey", storage: .userDefaults)
var exampleValue: String = "default"

// Example usage of StorableValue with KeychainStorage
@StorableValue(key: "exampleKey", storage: .userDefaults)
var secureValue: ExampleStruct? = nil

enum ExampleEnum: String, Codable {
    case firstCase
    case secondCase
}

struct ExampleStruct: Codable {
    var intValue: Int
    var stringValue: String
    var enumValue: ExampleEnum
}

secureValue = ExampleStruct(intValue: 123, stringValue: "example", enumValue: .firstCase)
```

Contributing
------------

Contributions to SwiftHelpers are welcome! Feel free to submit a pull request with new features, improvements, or bug fixes. Please make sure to add documentation and unit tests for any changes you make.

License
-------

SwiftHelpers is released under the MIT License. See the [LICENSE](License) file for more information.
