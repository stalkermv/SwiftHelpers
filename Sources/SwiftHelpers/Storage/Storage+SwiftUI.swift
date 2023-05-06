//
//  Created by Valeriy Malishevskyi on 06.05.2023.
//

import SwiftUI

public extension View {
    func storageDisabled(_ disabled: Bool = true) -> some View {
        self.environment(\.isStorageEnabled, !disabled)
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
