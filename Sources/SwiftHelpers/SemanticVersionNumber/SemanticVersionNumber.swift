//
//  SemanticVersionNumber.swift
//  SwiftHelpers
//
//  Created by Valeriy Malishevskyi on 16.10.2024.
//

import Foundation

/// A value type representing a semantic version number in the format `MAJOR.MINOR.PATCH`.
///
/// `SemanticVersionNumber` is designed to parse and model semantic versions, such as `"1.0.0"`,
/// and can be initialized from either integer components or string representations.
public struct SemanticVersionNumber: Equatable {

    /// The major version component.
    ///
    /// Typically incremented for incompatible API changes.
    public let major: Int

    /// The minor version component.
    ///
    /// Typically incremented for backward-compatible functionality.
    public let minor: Int

    /// The patch version component.
    ///
    /// Typically incremented for backward-compatible bug fixes.
    public let patch: Int

    /// Initializes a `SemanticVersionNumber` from a dot-separated version string.
    ///
    /// This initializer attempts to parse the version string into three integer components:
    /// major, minor, and patch. The string must be in the format `"X.Y.Z"`.
    ///
    /// ```swift
    /// let version = SemanticVersionNumber(version: "2.1.3")
    /// print(version?.major) // 2
    /// ```
    ///
    /// - Parameter version: A string formatted as `"MAJOR.MINOR.PATCH"`.
    /// - Returns: `nil` if the string is improperly formatted or contains non-integer components.
    public init?(version: String) {
        let components = version.split(separator: ".")
        guard components.count == 3 else { return nil }

        self.init(
            major: String(components[0]),
            minor: String(components[1]),
            patch: String(components[2])
        )
    }

    /// Initializes a `SemanticVersionNumber` from string components.
    ///
    /// Converts the string values for major, minor, and patch into integers. Fails
    /// if any of the strings cannot be parsed as integers.
    ///
    /// ```swift
    /// let version = SemanticVersionNumber(major: "1", minor: "0", patch: "5")
    /// print(version?.patch) // 5
    /// ```
    ///
    /// - Parameters:
    ///   - major: A string representing the major version.
    ///   - minor: A string representing the minor version.
    ///   - patch: A string representing the patch version.
    /// - Returns: `nil` if any component cannot be converted to an integer.
    public init?(major: String, minor: String, patch: String) {
        guard
            let majorAsInt = Int(major),
            let minorAsInt = Int(minor),
            let patchAsInt = Int(patch)
        else {
            return nil
        }

        self.init(
            major: majorAsInt,
            minor: minorAsInt,
            patch: patchAsInt
        )
    }

    /// Initializes a `SemanticVersionNumber` from integer components.
    ///
    /// Use this initializer when you already have validated version numbers as integers.
    ///
    /// ```swift
    /// let version = SemanticVersionNumber(major: 3, minor: 2, patch: 0)
    /// ```
    ///
    /// - Parameters:
    ///   - major: The major version number.
    ///   - minor: The minor version number.
    ///   - patch: The patch version number.
    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
}

extension SemanticVersionNumber: Comparable {
    public static func <(lhs: SemanticVersionNumber, rhs: SemanticVersionNumber) -> Bool {
        return (lhs.major < rhs.major)
        || (lhs.major == rhs.major && lhs.minor < rhs.minor)
        || (lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch < rhs.patch)
        || (lhs.major == rhs.major && lhs.minor < rhs.minor)
        || (lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch < rhs.patch)
    }
}

extension SemanticVersionNumber: CustomStringConvertible {
    public var description: String {
        return "\(major).\(minor).\(patch)"
    }
}
