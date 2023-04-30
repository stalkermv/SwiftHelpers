//
//  Created by Valeriy Malishevskyi on 02.09.2022.
//

import Foundation

public extension URL {
    /// A computed property that returns the query parameters of a URL as a dictionary.
    /// - Returns: A dictionary of query parameters with keys as parameter names and values as parameter values.
    /// Returns `nil` if the URL has no query parameters.
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
                  return nil
              }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
