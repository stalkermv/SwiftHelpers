//
//  File.swift
//  
//
//  Created by Valeriy Malishevskyi on 30.08.2022.
//

import Foundation

/// Check if method throws or not
/// - Parameter method: any throwing method
/// - Returns: if method throws return false
public func isFunctionPass(_ method: () throws -> Void) -> Bool {
    do {
        try method()
        return true
    } catch {
        return false
    }
}
