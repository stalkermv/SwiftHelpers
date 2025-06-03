//
//  Bundle+Version.swift
//  SwiftHelpers
//
//  Created by Valeriy Malishevskyi on 23.02.2025.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension Bundle {

    /// Returns the semantic version number of the app from the `CFBundleShortVersionString` in the main bundle.
    ///
    /// This value is typically set in your app's `Info.plist` under the key `CFBundleShortVersionString`.
    /// It is expected to be in the format `"MAJOR.MINOR.PATCH"`.
    ///
    /// ```swift
    /// let version = Bundle.main.appVersion
    /// print(version) // SemanticVersionNumber(major: 1, minor: 2, patch: 3)
    /// ```
    ///
    /// - Returns: A `SemanticVersionNumber` representing the app's version.
    /// - Note: This method will crash with a `fatalError` if the version string is missing or improperly formatted.
    var appVersion: SemanticVersionNumber {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            fatalError("Could not read CFBundleShortVersionString from Info.plist")
        }
        return SemanticVersionNumber(version: version)!
    }
}

extension Bundle {

    /// Asynchronously retrieves the current App Store version for the app using its bundle identifier.
    ///
    /// This property sends a request to the iTunes Lookup API using the app's `bundleIdentifier`
    /// and attempts to parse the latest version number returned from the App Store.
    ///
    /// ```swift
    /// Task {
    ///     if let storeVersion = try await Bundle.main.currentAppStoreVersion {
    ///         print("Current App Store version: \(storeVersion)")
    ///     }
    /// }
    /// ```
    ///
    /// - Returns: A `SemanticVersionNumber` if the version could be retrieved and parsed; otherwise, `nil`.
    /// - Throws: An error if the network request fails or the data cannot be parsed.
    public var currentAppStoreVersion: SemanticVersionNumber? {
        get async throws {
            guard let bundleId = bundleIdentifier else { return nil }
            let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)")
            let (data, _) = try await URLSession.shared.data(from: url!)
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            guard let result = json?["results"] as? [[String: Any]] else { return nil }
            let version = result.first?["version"] as? String
            
            return SemanticVersionNumber(version: version ?? "")
        }
    }
}
