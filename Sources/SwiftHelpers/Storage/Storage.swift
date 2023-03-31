//
//  Created by Valeriy Malishevskyi on 25.07.2022.
//

import Foundation

public protocol Storage {
    func save<T: Encodable>(_ object: T, key: String) throws
    func load<T: Decodable>(key: String) throws -> T?
    func remove(key: String) throws
    
    func saveString(_ string: String?, key: String) throws
    func loadString(key: String) throws -> String?
}

public protocol AsyncStorage {
    func save<T: Encodable>(_ object: T, key: String) async throws
    func load<T: Decodable>(key: String) async throws -> T?
    func remove(key: String) async throws
}
