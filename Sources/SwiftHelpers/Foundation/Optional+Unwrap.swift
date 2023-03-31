//
//  Optional+Unwrap.swift
//  
//
//  Created by Valeriy Malishevskyi on 27.01.2022.
//

import Foundation

public extension Optional {
    func unwrap(or error: Error) throws -> Wrapped {
        guard let value = self else {
            throw error
        }
        return value
    }
}
