//
//  Created by Valeriy Malishevskyi on 30.08.2022.
//

import Foundation
import SwiftHelpers

public final class KeychainStorage: Storage {

    private enum KeychainKey {
        static let bundle = Bundle.main.bundleIdentifier ?? "bundle"
        static let serviceName = "\(bundle).keychain.environment"
        static let environment = "environment"
    }

    private let keychain = Keychain(serviceName: KeychainKey.serviceName, accessMode: kSecAttrAccessibleWhenUnlocked as String)

    func set(_ data: Data?, forKey defaultName: String) {
        guard let data = data else { return }
        keychain.addOrUpdate(key: defaultName, data: data)
    }

    func data(forKey defaultName: String) -> Data? {
        try? keychain.getData(key: defaultName)
    }

    func decodable<T: Decodable>(_ type: T.Type, forKey defaultName: String) -> T? {
        keychain.get(key: defaultName)
    }

    func removeObject(forKey defaultName: String) {
        try? keychain.remove(key: defaultName)
    }
}

public extension KeychainStorage {
    func save<T>(_ object: T, key: String) throws where T : Encodable {
        guard let value = try? JSONEncoder().encode(object) else { return }
        set(value, forKey: key)
    }
    
    func load<T>(key: String) throws -> T? where T : Decodable {
        decodable(T.self, forKey: key)
    }
    
    func remove(key: String) throws {
        removeObject(forKey: key)
    }
    
    func saveString(_ string: String?, key: String) throws {
        if let string {
            try keychain.updateValue(key: key, newValue: string)
        } else {
            try keychain.remove(key: key)
        }
    }
    
    func loadString(key: String) throws -> String? {
        try keychain.getValue(key: key)
    }
}

public extension Storage where Self == KeychainStorage {
    
    /// Default variant implementations for `KeyValueStore`
    static var keychain: Storage {
        KeychainStorage()
    }
}
