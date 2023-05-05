//  MIT License
//
//  Copyright (c) 2023 Maksym Kuznietsov
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
