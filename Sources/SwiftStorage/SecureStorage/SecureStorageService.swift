//
//  SecureStorageService.swift
//  SwiftUIHelpers
//
//  Created by Valeriy Malishevskyi on 04.09.2024.
//

@MainActor
public protocol SecureStorageService {
    func value<T: Decodable>(type: T.Type, forKey key: String) throws -> T
    func set<T: Encodable>(_ value: T, forKey key: String) throws
    func subscribe(subscription: Subscription)
    func unsubscribe(subscription: Subscription)
}
