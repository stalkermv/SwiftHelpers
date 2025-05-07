//
//  ProcessInfo+isPreview.swift
//  SwiftHelpers
//
//  Created by Valeriy Malishevskyi on 07.05.2025.
//

import Foundation

// MARK: - ProcessInfo Extensions

public extension ProcessInfo {
    /// Checks if the current process is running in a SwiftUI preview.
    var isPreview: Bool {
        environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    /// Checks if the current process is running in a SwiftUI preview.
    /// Static version of the `processInfo` instance property for easier usage.
    static var isPreview: Bool {
        processInfo.isPreview
    }
}
