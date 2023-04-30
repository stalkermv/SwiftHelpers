//
//  Created by Valeriy Malishevskyi on 25.07.2022.
//

import Foundation

/// A property wrapper that makes a value conform to `Equatable` without adding any additional logic.
@propertyWrapper
public struct EquatableNoop<Value>: Equatable {
    public var wrappedValue: Value

    /// Initializes a new instance of the property wrapper with the specified wrapped value.
    public init(wrappedValue value: Value) {
        self.wrappedValue = value
    }

    public static func == (lhs: EquatableNoop<Value>, rhs: EquatableNoop<Value>) -> Bool { true }
}
