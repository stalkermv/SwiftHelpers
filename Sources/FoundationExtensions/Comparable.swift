//
//  Created by Valeriy Malishevskyi on 25.11.2022.
//

import Foundation

public extension Comparable {
    
    /// Returns the value clamped to the specified closed range.
    ///
    /// - Parameter limits: A closed range representing the lower and upper bounds of the clamping range.
    /// - Returns: The clamped value.
    ///
    /// This function clamps the value to the provided closed range, ensuring that the returned value is within the specified limits.
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
