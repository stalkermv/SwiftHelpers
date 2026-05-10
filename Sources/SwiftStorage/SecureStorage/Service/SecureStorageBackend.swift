import Combine
import Foundation

public protocol SecureStorageBackend: AnyObject, Sendable {
    func data(forKey key: String) throws -> Data?
    func setData(_ data: Data?, forKey key: String) throws
    func updates(forKey key: String) -> AnyPublisher<Void, Never>
}

internal enum SecureStorageUpdateBus {
    private static func notificationName(for scope: String) -> Notification.Name {
        Notification.Name("SwiftStorage.SecureStorageBackend.\(scope)")
    }

    static func post(scope: String, key: String) {
        NotificationCenter.default.post(
            name: notificationName(for: scope),
            object: nil,
            userInfo: ["key": key]
        )
    }

    static func publisher(scope: String, key: String) -> AnyPublisher<Void, Never> {
        NotificationCenter.default.publisher(for: notificationName(for: scope))
            .compactMap { $0.userInfo?["key"] as? String }
            .filter { $0 == key }
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
