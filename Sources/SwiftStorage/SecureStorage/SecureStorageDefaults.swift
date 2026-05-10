import Foundation

extension Bundle {
    var secureStorageServiceName: String {
        bundleIdentifier ?? "SwiftStorage"
    }
}
