//
//  HexColorContainer.swift
//  SwiftHelpers
//
//  Created by Valeriy Malishevskyi on 05.08.2024.
//

import Foundation

public struct HexColorContainer: Sendable, Hashable {
    
    public let red: CGFloat
    public let green: CGFloat
    public let blue: CGFloat
    
    public init?(_ hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&int) else { return nil }
        self.red = CGFloat((int & 0xFF0000) >> 16) / 255.0
        self.green = CGFloat((int & 0x00FF00) >> 8) / 255.0
        self.blue = CGFloat(int & 0x0000FF) / 255.0
    }
}
