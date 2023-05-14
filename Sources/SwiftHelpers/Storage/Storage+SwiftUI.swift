//
//  Created by Valeriy Malishevskyi on 06.05.2023.
//

import SwiftUI

public extension View {
    /// A view modifier that disables or enables storage for `StorableValue` instances within the view hierarchy.
    ///
    /// When storage is disabled, any changes to `StorableValue` instances will only affect the in-memory value and will not be persisted to storage.
    /// When storage is enabled, changes to `StorableValue` instances will be persisted to storage.
    ///
    /// - Parameter disabled: A Boolean value that indicates whether storage should be disabled. The default value is `true`, which disables storage.
    ///
    /// - Returns: A modified view that has the storage setting applied to its environment.
    func storageDisabled(_ disabled: Bool = true) -> some View {
        environment(\.isStorageEnabled, !disabled)
    }
}

extension EnvironmentValues {
    var isStorageEnabled: Bool {
        get { self[StorageEnabledKey.self] }
        set { self[StorageEnabledKey.self] = newValue }
    }
}

private struct StorageEnabledKey: EnvironmentKey {
    static let defaultValue: Bool = true
}
