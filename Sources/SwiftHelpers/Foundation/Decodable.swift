//
//  Created by Valeriy Malishevskyi on 30.08.2022.
//

import Foundation

public extension Decodable {
    /// Creates an instance of the conforming type from the provided JSON data.
    ///
    /// This function attempts to decode the provided JSON data into an instance of the conforming type using
    /// `JSONDecoder`. If the data cannot be decoded, an error will be logged, and the function returns `nil`.
    ///
    /// - Parameter data: The JSON data to be decoded into an instance of the conforming type.
    /// - Returns: An instance of the conforming type created from the decoded JSON data, or `nil` if decoding fails.
    static func from(data: Data) -> Self? {
        do {
            return try JSONDecoder().decode(Self.self, from: data)
        } catch {
            print("Error decoding decodable in function: \(#function), line: \(#line). Given error \(error)")
            return nil
        }
    }
}
