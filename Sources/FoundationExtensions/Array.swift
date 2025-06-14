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

public extension Array {
    
    /// Sorts the array by a property of type `T` using the provided KeyPath.
    ///
    /// - Parameters:
    ///   - keyPath: The KeyPath to the property of type `T` that should be used for sorting.
    ///   - ascending: A boolean value indicating the desired sort order. If true (default), the array will be sorted in ascending order. If false, the array will be sorted in descending order.
    /// - Returns: A new array containing the sorted elements.
    ///
    /// This method sorts the array by comparing the values of the specified property. It does not handle optional properties.
    /// For optional properties, use the other `sorted` method that takes a KeyPath to a property of type `T?`.
    func sorted<T: Comparable>(keyPath: KeyPath<Element, T>, ascending: Bool = true) -> Self {
        func comparator(_ lhs: T, _ rhs: T, _ comparator: (T, T) -> Bool) -> Bool { comparator(lhs, rhs) }
        
        return sorted { comparator($0[keyPath: keyPath], $1[keyPath: keyPath], ascending ? (<) : (>)) }
    }
    
    /// Sorts the array by an optional property of type `T` using the provided KeyPath.
    ///
    /// - Parameters:
    ///   - keyPath: The KeyPath to the optional property of type `T` that should be used for sorting.
    ///   - ascending: A boolean value indicating the desired sort order.
    ///   If true (default), the array will be sorted in ascending order. If false, the array will be sorted in descending order.
    /// - Returns: A new array containing the sorted elements.
    ///
    /// This method sorts the array by comparing the values of the specified optional property.
    /// It handles optional properties (`T?`) differently than non-optional properties.
    /// When sorting, elements with a `nil` value for the specified property will always appear at the end of the array,
    /// regardless of the sort order.
    /// In other words, when sorting in ascending order,  non-`nil` values come first, followed by `nil` values;
    /// when sorting in descending order, non-`nil` values still come first, followed by `nil` values.
    func sorted<T: Comparable>(keyPath: KeyPath<Element, T?>, ascending: Bool = true) -> Self {
        sorted {
            let lhs = $0[keyPath: keyPath]
            let rhs = $1[keyPath: keyPath]
            
            switch (lhs, rhs) {
            case let (.some(l), .some(r)):
                return ascending ? l < r : l > r
            case (.some, .none):
                return true
            case (.none, .some):
                return false
            case (.none, .none):
                return false
            }
        }
    }
}

public extension Array {
    /// Returns the element at the specified index if it is within the bounds of the array.
    ///
    /// - Parameter index: The index of the element to retrieve.
    /// - Returns: The element at the specified index if it exists, otherwise nil.
    ///
    /// This subscript is a safe alternative to the standard subscript for arrays.
    /// Instead of causing a runtime error when accessing an out-of-bounds index, this subscript returns nil.
    subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }
}

extension Array {
    public subscript(index: Int, default defaultValue: @autoclosure () -> Element) -> Element {
        guard index >= 0, index < count else { return defaultValue() }
        return self[index]
    }
}

public extension Array {
    /// Returns a new array with elements that are mutated using the provided mutation function.
    ///
    /// - Parameter mutation: A function that takes an inout element and applies a mutation to it.
    /// - Returns: A new array with the mutated elements.
    ///
    /// This function allows you to apply a mutation to each element in the array and returns a new array with the mutated elements.
    /// The original array remains unchanged.
    ///
    /// The difference between `mutate` and `map` is that `mutate` uses an inout parameter in the mutation closure,
    /// allowing you to modify the element directly without needing to return it.
    /// This can make the code more concise and easier to read, especially when performing complex mutations.
    /// However, keep in mind that the `mutate` function is still non-destructive, returning a new array with the mutated elements.
    ///
    /// Example:
    /// ```
    /// let testArray = [1, 2, 3, 4, 5]
    ///
    /// let mutatedArray = testArray.mutate { element in
    ///     element *= 2
    /// }
    ///
    /// print(mutatedArray) // Output: [2, 4, 6, 8, 10]
    /// ```
    func mutate(_ mutation: (_ element: inout Element) -> Void) -> [Element] {
        map { element in
            var mutableElement = element
            mutation(&mutableElement)
            return mutableElement
        }
    }
}

public extension Array {
    /// Returns the first index where the specified value appears in the array.
    ///
    /// This method searches the array for the first element that matches the specified value at a given key path. 
    /// It's useful for finding an element in an array of complex objects based on one of the object's properties.
    ///
    /// - Parameters:
    ///   - element: The element to search for in the array.
    ///   - keyPath: A key path to a specific property of the element to compare.
    /// - Returns: The first index where the specified value is found, or `nil` if the value is not found.
    ///
    /// Usage Example:
    /// ```
    /// struct Person {
    ///     var id: Int
    ///     var name: String
    /// }
    ///
    /// let people = [Person(id: 1, name: "Alice"), Person(id: 2, name: "Bob")]
    /// if let index = people.firstIndex(of: Person(id: 2, name: "Bob"), by: \.id) {
    ///     print("Found at index \(index)")
    /// }
    /// ```
    func firstIndex<Value: Equatable>(of element: Element, by keyPath: KeyPath<Element, Value>) -> Int? {
        firstIndex(where: { $0[keyPath: keyPath] == element[keyPath: keyPath] })
    }
}

public extension Array {
    /// Appends a new element to the array and returns a new array.
    ///
    /// This method creates a new array by appending the given element to the end of the original array.
    /// It's useful when you need to append an element but also need to retain the original array unchanged.
    ///
    /// - Parameter element: The element to append to the array.
    /// - Returns: A new array that includes the original elements plus the new element.
    ///
    /// Usage:
    /// ```swift
    /// let numbers = [1, 2, 3]
    /// let newNumbers = numbers.appending(4)
    /// // numbers is still [1, 2, 3]
    /// // newNumbers is [1, 2, 3, 4]
    /// ```
    @inlinable func appending(_ element: Element) -> Array {
        return self + [element]
    }
}
