#if canImport(SwiftUI)
import Combine
import Foundation
import FoundationExtensions
import SwiftUI

@MainActor
final class SecureStorageState<Value: Codable & Sendable>: ObservableObject {
    @Published private(set) var value: Value
    @Published private(set) var error: Error?

    private let key: String
    private let defaultValue: Value
    private var backend: (any SecureStorageBackend)?
    private var updatesCancellable: AnyCancellable?

    init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
        self.value = defaultValue
    }

    func bind(to backend: any SecureStorageBackend) {
        if let current = self.backend, current === backend {
            return
        }

        self.backend = backend
        updatesCancellable = backend
            .updates(forKey: key)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.reloadFromBackend()
            }
        reloadFromBackend()
    }

    func setValue(_ newValue: Value) {
        guard let backend else {
            value = newValue
            error = nil
            return
        }

        do {
            let persisted = try encodedData(for: newValue)
            try backend.setData(persisted, forKey: key)
            value = persisted == nil ? defaultValue : newValue
            error = nil
        } catch {
            self.error = error
        }
    }

    private func reloadFromBackend() {
        guard let backend else {
            value = defaultValue
            error = nil
            return
        }

        do {
            guard let data = try backend.data(forKey: key) else {
                value = defaultValue
                error = nil
                return
            }

            value = try JSONDecoder().decode(Value.self, from: data)
            error = nil
        } catch {
            self.error = error
        }
    }

    private func encodedData(for value: Value) throws -> Data? {
        if let optional = value as? any OptionalProtocol, optional.isNone {
            return nil
        }

        do {
            return try JSONEncoder().encode(value)
        } catch {
            throw SecureStorageError.encodingFailed
        }
    }
}
#endif
