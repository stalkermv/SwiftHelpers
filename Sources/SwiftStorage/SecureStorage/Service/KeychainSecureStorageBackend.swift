import Combine
import Foundation

public final class KeychainSecureStorageBackend: SecureStorageBackend {
    public let serviceName: String
    public let accessMode: String
    public let accessGroup: String?

    private let scope: String

    public init(
        serviceName: String = Bundle.main.bundleIdentifier ?? "SwiftStorage",
        accessMode: String = kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String,
        accessGroup: String? = nil
    ) {
        self.serviceName = serviceName
        self.accessMode = accessMode
        self.accessGroup = accessGroup
        self.scope = ["keychain", serviceName, accessMode, accessGroup ?? ""].joined(separator: ":")
    }

    public func data(forKey key: String) throws -> Data? {
        do {
            return try makeKeychain().getData(key: key)
        } catch let error as Keychain.Errors {
            throw SecureStorageError.from(keychainError: error)
        } catch {
            throw error
        }
    }

    public func setData(_ data: Data?, forKey key: String) throws {
        do {
            let keychain = makeKeychain()
            if let data {
                keychain.addOrUpdate(key: key, data: data)
            } else {
                try keychain.remove(key: key)
            }
            SecureStorageUpdateBus.post(scope: scope, key: key)
        } catch let error as Keychain.Errors {
            throw SecureStorageError.from(keychainError: error)
        } catch {
            throw error
        }
    }

    public func updates(forKey key: String) -> AnyPublisher<Void, Never> {
        SecureStorageUpdateBus.publisher(scope: scope, key: key)
    }

    static func canAccess(
        serviceName: String,
        accessMode: String,
        accessGroup: String? = nil
    ) -> Bool {
        let probeKey = "__swiftstorage_probe__\(UUID().uuidString)"
        let keychain = Keychain(
            serviceName: serviceName,
            accessMode: accessMode,
            accessGroup: accessGroup
        )

        do {
            try keychain.addData(key: probeKey, data: Data([0x01]))
            try keychain.remove(key: probeKey)
            return true
        } catch {
            return false
        }
    }

    private func makeKeychain() -> Keychain {
        Keychain(
            serviceName: serviceName,
            accessMode: accessMode,
            accessGroup: accessGroup
        )
    }
}

private extension SecureStorageError {
    static func from(keychainError: Keychain.Errors) -> SecureStorageError {
        switch keychainError {
        case .apiCallFailed(let statusCode):
            return .keychainFailure(status: statusCode)
        case .invalidValue, .conversionError:
            return .fileSystemFailure(String(describing: keychainError))
        }
    }
}

