import Foundation

public enum SecureStorageError: Error, Equatable {
    case encodingFailed
    case decodingFailed
    case keychainFailure(status: OSStatus)
    case fileSystemFailure(String)
}
