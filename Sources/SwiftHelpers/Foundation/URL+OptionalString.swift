//
//  URL+OptionalString.swift
//  
//
//  Created by Valeriy Malishevskyi on 28.12.2021.
//

import Foundation

public extension URL {
    init?(string: String?) {
        guard let string = string else {
            return nil
        }

        self.init(string: string)
    }
}
