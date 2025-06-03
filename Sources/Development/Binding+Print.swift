//
//  Binding+Print.swift
//  SwiftUIHelpers
//
//  Created by Valeriy Malishevskyi on 06.10.2024.
//

#if canImport(SwiftUI)
import SwiftUI

extension Binding {

    /// Returns a binding that logs its value whenever it is read or written.
    ///
    /// This method wraps the original binding in a debug-printing layer. When the binding's
    /// value is read (`get`) or written (`set`), a message is printed to the console, optionally
    /// with a custom prefix and a value formatting closure.
    ///
    /// ```swift
    /// @State private var count = 0
    ///
    /// var body: some View {
    ///     Stepper("Count", value: $count.print("Counter"))
    /// }
    /// // Console:
    /// // {< GET} Counter: 0
    /// // {> SET} Counter: 1
    /// ```
    ///
    /// - Parameters:
    ///   - prefix: A string printed before the value to identify the binding. Defaults to an empty string.
    ///   - format: A closure to format the bound value for printing. Defaults to using the value's `description`.
    /// - Returns: A new `Binding` that logs accesses and updates.
    @MainActor
    public func print(
        _ prefix: String = "",
        format: @escaping (Value) -> String = { "\($0)" }
    ) -> Self {
        Binding(
            get: {
                Swift.print("{< GET} \(prefix): \(format(wrappedValue))")
                return wrappedValue
            },
            set: {
                Swift.print("{> SET} \(prefix): \(format($0))")
                wrappedValue = $0
            }
        )
    }
}
#endif
