//
//  Created by Valeriy Malishevskyi on 25.07.2022.
//

import Foundation

public extension Bundle {
    var appVersion: String {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    var buildNumber: Int {
        let build: NSString = self.infoDictionary?["CFBundleVersion"] as? NSString ?? "1"
        return Int(build.intValue)
    }
    
    var appVersionWithBuildNumber: String {
        return "\(appVersion) (\(buildNumber))"
    }
}

