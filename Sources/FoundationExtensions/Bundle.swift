//
//  Created by Valeriy Malishevskyi on 25.07.2022.
//

import Foundation

public extension Bundle {

    /// The short version string of the app (e.g., "1.2.3").
    ///
    /// This value is read from the `CFBundleShortVersionString` key in the Info.plist.
    /// If the value is not present, an empty string is returned.
    ///
    /// ```swift
    /// let version = Bundle.main.appVersionString
    /// print(version) // "1.0"
    /// ```
    var appVersionString: String {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    /// The build number of the app as an integer.
    ///
    /// This value is read from the `CFBundleVersion` key in the Info.plist.
    /// If the value is missing or invalid, `1` is used as the default.
    ///
    /// ```swift
    /// let build = Bundle.main.buildNumber
    /// print(build) // 42
    /// ```
    var buildNumber: Int {
        let build: NSString = self.infoDictionary?["CFBundleVersion"] as? NSString ?? "1"
        return Int(build.intValue)
    }

    /// A formatted string containing the app version and build number.
    ///
    /// The format is: `<version> (<build>)`. For example: `"1.0 (42)"`.
    ///
    /// ```swift
    /// let versionWithBuild = Bundle.main.appVersionWithBuildNumber
    /// print(versionWithBuild) // "1.0 (42)"
    /// ```
    var appVersionWithBuildNumber: String {
        return "\(appVersionString) (\(buildNumber))"
    }

    /// The URL pointing to the production receipt location, if available.
    ///
    /// This returns the expected location of the production receipt by adjusting the path
    /// of the app store receipt URL. Useful when validating receipts manually.
    ///
    /// ```swift
    /// if let url = Bundle.main.appStoreProductionReceiptURL {
    ///     print(url.path)
    /// }
    /// ```
    var appStoreProductionReceiptURL: URL? {
        appStoreReceiptURL?
            .deletingLastPathComponent()
            .appendingPathComponent("receipt")
    }

    /// A Boolean value indicating whether the app is running in a production environment.
    ///
    /// In `DEBUG` builds, this always returns `false`.
    /// In non-`DEBUG` builds, it checks whether the receipt URL contains `"sandboxReceipt"`.
    ///
    /// ```swift
    /// if Bundle.main.isProduction {
    ///     // Perform production-only logic
    /// }
    /// ```
    var isProduction: Bool {
    #if DEBUG
        return false
    #else
        guard let path = self.appStoreReceiptURL?.path else {
            return true
        }
        return !path.contains("sandboxReceipt")
    #endif
    }
}
