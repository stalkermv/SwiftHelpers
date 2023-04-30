//
//  Created by Valeriy Malishevskyi on 25.07.2022.
//

import Foundation

/// A protocol that defines a storage object for storing and retrieving encoded objects.
///
/// The `Storage` protocol defines a set of methods for saving, loading, and removing encoded objects from a storage object.
/// The storage object can be any object that conforms to the `Storage` protocol.
///
/// The `Storage` protocol is generic over a type `T` that conforms to `Encodable` for saving objects, and `Decodable` for loading objects.
///
/// - Note: The `Storage` protocol is designed to be synchronous.
/// If you need to perform storage operations asynchronously, use the `AsyncStorage` protocol instead.
public protocol Storage {
    /// Saves an object to the storage object with the specified key.
    /// - Parameters:
    ///   - object: The object to save.
    ///   - key: The key to use for the object in the storage object.
    func save<T: Encodable>(_ object: T, key: String) throws
    /// Loads an object from the storage object with the specified key.
    /// - Parameter key: The key to use for the object in the storage object.
    /// - Returns: The object loaded from the storage object, or `nil` if the object was not found.
    func load<T: Decodable>(key: String) throws -> T?
    /// Removes an object from the storage object with the specified key.
    /// - Parameter key: The key to use for the object in the storage object.
    func remove(key: String) throws
}

/// A protocol that defines an asynchronous storage object for storing and retrieving encoded objects.
///
/// The `AsyncStorage` protocol defines a set of methods for saving, loading,
/// and removing encoded objects from a storage object asynchronously.
/// The storage object can be any object that conforms to the `AsyncStorage` protocol.
///
/// The `AsyncStorage` protocol is generic over a type `T` that conforms to `Encodable` for saving objects,
/// and `Decodable` for loading objects.
public protocol AsyncStorage {
    /// Saves an object to the storage object with the specified key asynchronously.
    /// - Parameters:
    ///   - object: The object to save.
    ///   - key: The key to use for the object in the storage object.
    func save<T: Encodable>(_ object: T, key: String) async throws
    /// Loads an object from the storage object with the specified key asynchronously.
    /// - Parameter key: The key to use for the object in the storage object.
    /// - Returns: The object loaded from the storage object, or `nil` if the object was not found.
    func load<T: Decodable>(key: String) async throws -> T?
    /// Removes an object from the storage object with the specified key.
    /// - Parameter key: The key to use for the object in the storage object.
    func remove(key: String) async throws
}
