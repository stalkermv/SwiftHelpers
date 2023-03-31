//
//  Created by Valeriy Malishevskyi on 30.08.2022.
//

import Foundation

public extension Decodable {
    static func from(data: Data) -> Self? {
        do {
            return try JSONDecoder().decode(Self.self, from: data)
        } catch {
            print("Error decoding decodable in function: \(#function), line: \(#line). Given error \(error)")
            return nil
        }
    }
}
