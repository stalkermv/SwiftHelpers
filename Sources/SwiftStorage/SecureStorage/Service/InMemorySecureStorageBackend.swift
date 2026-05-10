import Combine
import Dispatch
import Foundation

public final class InMemorySecureStorageBackend: SecureStorageBackend {
    private let scope: String
    private let queue: DispatchQueue
    nonisolated(unsafe) private var storage: [String: Data]

    public init(scope: String = UUID().uuidString) {
        self.scope = "inmemory:\(scope)"
        self.queue = DispatchQueue(label: "SwiftStorage.InMemorySecureStorageBackend.\(scope)")
        self.storage = [:]
    }

    public func data(forKey key: String) throws -> Data? {
        queue.sync { storage[key] }
    }

    public func setData(_ data: Data?, forKey key: String) throws {
        queue.sync {
            if let data {
                storage[key] = data
            } else {
                storage.removeValue(forKey: key)
            }
        }
        SecureStorageUpdateBus.post(scope: scope, key: key)
    }

    public func updates(forKey key: String) -> AnyPublisher<Void, Never> {
        SecureStorageUpdateBus.publisher(scope: scope, key: key)
    }
}
