//
//  Created by Valeriy Malishevskyi on 25.07.2022.
//

import Foundation

public extension Date {
    var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: self) ?? self
    }
    
    var tomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: self) ?? self
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

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
    
    @available(iOS 15.0, *)
    static func iso8601(string: String) -> Date {
        let dateFormatStyle = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
        
        do {
            let date = try Date(string, strategy: dateFormatStyle)
            return date
        } catch {
            assertionFailure("Parse date error:" + "\(error)" + "for response \(self)")
            return .distantFuture
        }
    }
}
