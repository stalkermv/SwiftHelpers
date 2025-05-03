//
//  Calendar+Current.swift
//  SwiftHelpers
//
//  Created by Valeriy Malishevskyi on 14.08.2024.
//

import Foundation

extension Calendar {

    /// Returns the current calendar with a specified time zone.
    ///
    /// This method returns a copy of `Calendar.current` with its `timeZone` property
    /// set to the given value. It is useful for performing date calculations or formatting
    /// using the current locale and settings, but in a specific time zone.
    ///
    /// ```swift
    /// let pstCalendar = Calendar.current(TimeZone(identifier: "America/Los_Angeles")!)
    /// print(pstCalendar.timeZone) // America/Los_Angeles (PST)
    /// ```
    ///
    /// - Parameter timeZone: The time zone to assign to the calendar.
    /// - Returns: A `Calendar` instance with the current settings and the specified time zone.
    public static func current(_ timeZone: TimeZone) -> Calendar {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar
    }
}
