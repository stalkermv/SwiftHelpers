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

public extension Date {
    /// The date representing yesterday.
    var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: self) ?? self
    }
    
    /// The date representing tomorrow.
    var tomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: self) ?? self
    }
    
    /// The start of the current day.
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// The end of the current day.
    var endOfDay: Date? {
        let components = DateComponents(hour: 23, minute: 59, second: 59)
        return Calendar.current.date(byAdding: components, to: startOfDay)
    }
    
    func dateByAdding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    var noon: Date {
        Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
    var day: Int {
        Calendar.current.component(.day,  from: self)
    }
    
    var month: Int {
        Calendar.current.component(.month,  from: self)
    }
    
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }
    
    var isLastDayOfMonth: Bool {
        tomorrow.month != month
    }
    
    /// Sets the time from the specified date and returns a new date with the updated time.
    ///
    /// This function extracts the hour and minute components from the provided `timeDate` and sets them for the current date.
    /// - Parameter timeDate: The date from which the time components (hour and minute) will be extracted.
    /// - Returns: A new date with the updated time components.
    func setTime(from timeDate: Date) -> Date {
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: timeDate)
        var result = Calendar.current.date(bySetting: .hour, value: timeComponents.hour ?? 0, of: self) ?? self
        result = Calendar.current.date(bySetting: .minute, value: timeComponents.minute ?? 0, of: result) ?? result
        return result
    }
    
    func daysDiff(from dateFrom: Date) -> Int {
        abs(Calendar.current.dateComponents([.day], from: dateFrom, to: self).day ?? 0)
    }
    
    enum ComponentToAdd {
        case seconds(Int)
        case minutes(Int)
        case hours(Int)
        case days(Int)
        case weeks(Int)
        case months(Int)
        case years(Int)
        
        var dict: (key: Calendar.Component, value: Int) {
            switch self {
            case .seconds(let value):
                return (.second, value)
            case .minutes(let value):
                return (.minute, value)
            case .hours(let value):
                return (.hour, value)
            case .days(let value):
                return (.day, value)
            case .weeks(let value):
                return (.day, value * 7)
            case .months(let value):
                return (.month, value)
            case .years(let value):
                return (.year, value)
            }
        }
        
        static func from(components: DateComponents) -> [ComponentToAdd] {
            var result: [ComponentToAdd] = []
            
            if let years = components.year, years != 0 {
                result.append(.years(years))
            }
            if let months = components.month, months != 0 {
                result.append(.months(months))
            }
            if let days = components.day, days != 0 {
                result.append(.days(days))
            }
            if let hours = components.hour, hours != 0 {
                result.append(.hours(hours))
            }
            if let minutes = components.minute, minutes != 0 {
                result.append(.minutes(minutes))
            }
            if let seconds = components.second, seconds != 0 {
                result.append(.seconds(seconds))
            }
            
            return result
        }
    }
    
    func add(_ component: ComponentToAdd) -> Date {
        Calendar.current.date(byAdding: component.dict.key, value: component.dict.value, to: self) ?? self
    }
    
    private func add(_ component: ComponentToAdd, to: Date? = nil) -> Date {
        let toDate = to ?? self
        return Calendar.current.date(byAdding: component.dict.key, value: component.dict.value, to: toDate) ?? toDate
    }
    
    func add(_ components: [ComponentToAdd]) -> Date {
        var date = self
        for component in components {
            date = add(component, to: date)
        }
        return date
    }
    
    func add(_ components: ComponentToAdd...) -> Date {
        add(components)
    }
    
    func isDayEquals(_ other: Date?) -> Bool {
        guard let other else { return false }
        return Calendar.current.isDate(self, inSameDayAs: other)
    }
}


public extension Date {
    
    /// Creates a new date from the given ISO 8601 formatted string.
    ///
    /// This function attempts to parse the provided ISO 8601 string using the `Date.ISO8601FormatStyle` format style
    /// with fractional seconds included. If the string cannot be parsed, a parsing error will be thrown.
    ///
    /// - Parameter string: The ISO 8601 formatted string to be parsed.
    /// - Throws: A parsing error if the provided string cannot be parsed into a date.
    /// - Returns: A new date object created from the parsed ISO 8601 string.
    /// - Requires: iOS 15.0 or later.
    @available(iOS 15.0, *)
    static func iso8601(string: String) throws -> Date {
        let dateFormatStyle = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
        let date = try Date(string, strategy: dateFormatStyle)
        return date
        
    }
}
