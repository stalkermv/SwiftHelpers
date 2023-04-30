//
//  Created by Valeriy Malishevskyi on 25.07.2022.
//

import Foundation

/// A property wrapper that makes a value conform to `Hashable` without adding any additional logic.
@propertyWrapper
public struct HashableNoop<Value: Equatable>: Hashable {
    public var wrappedValue: Value

    /// Initializes a new instance of the property wrapper with the specified wrapped value.
    ///
    /// - Parameter value: The initial value to wrap.
    public init(wrappedValue value: Value) {
        self.wrappedValue = value
    }

    public func hash(into hasher: inout Hasher) {}
}
