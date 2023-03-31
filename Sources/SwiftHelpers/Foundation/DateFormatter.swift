//
//  Created by Valeriy Malishevskyi on 17.10.2022.
//

import Foundation

public extension DateFormatter {
    func relativeString(from date: Date) -> String {
        let isToday = date.isDayEquals(Date())
        
        if isToday {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.doesRelativeDateFormatting = true
            return dateFormatter.string(from: date)
        } else {
            return self.string(from: date)
        }
    }
}
