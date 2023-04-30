//
//  Created by Valeriy Malishevskyi on 25.07.2022.
//

import Foundation

public extension Bundle {
    /// The app version as a string.
    var appVersion: String {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    /// Build number as an integer.
    var buildNumber: Int {
        let build: NSString = self.infoDictionary?["CFBundleVersion"] as? NSString ?? "1"
        return Int(build.intValue)
    }
    
    /// The app version and build number formatted as a string.
    var appVersionWithBuildNumber: String {
        return "\(appVersion) (\(buildNumber))"
    }
}

