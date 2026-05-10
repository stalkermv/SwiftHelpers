import Combine
import Foundation

public final class FileSecureStorageBackend: SecureStorageBackend {
    public let fileURL: URL

    private let scope: String

    public init(fileURL: URL) {
        self.fileURL = fileURL.standardizedFileURL
        self.scope = "file:\(self.fileURL.path)"
    }

    public func data(forKey key: String) throws -> Data? {
        try readDictionary()[key]
    }

    public func setData(_ data: Data?, forKey key: String) throws {
        var dictionary = try readDictionary()
        dictionary[key] = data
        if data == nil {
            dictionary.removeValue(forKey: key)
        }
        try writeDictionary(dictionary)
        SecureStorageUpdateBus.post(scope: scope, key: key)
    }

    public func updates(forKey key: String) -> AnyPublisher<Void, Never> {
        SecureStorageUpdateBus.publisher(scope: scope, key: key)
    }

    static func temporary(namespace: String) -> FileSecureStorageBackend {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("SwiftStorage", isDirectory: true)
        let fileURL = root.appendingPathComponent(sanitizedFileName(namespace)).appendingPathExtension("json")
        return FileSecureStorageBackend(fileURL: fileURL)
    }

    private func readDictionary() throws -> [String: Data] {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return [:]
        }

        do {
            let data = try Data(contentsOf: fileURL)
            if data.isEmpty {
                return [:]
            }
            return try JSONDecoder().decode([String: Data].self, from: data)
        } catch {
            throw SecureStorageError.fileSystemFailure(error.localizedDescription)
        }
    }

    private func writeDictionary(_ dictionary: [String: Data]) throws {
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let data = try JSONEncoder().encode(dictionary)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw SecureStorageError.fileSystemFailure(error.localizedDescription)
        }
    }

    private static func sanitizedFileName(_ namespace: String) -> String {
        let invalid = CharacterSet.alphanumerics.union(.init(charactersIn: "-_.")).inverted
        return namespace.unicodeScalars.map { scalar in
            invalid.contains(scalar) ? "_" : String(scalar)
        }.joined()
    }
}
