//
//  URL+Image.swift
//  
//
//  Created by Valeriy Malishevskyi on 16.06.2024.
//

import Foundation

extension URL {
    @available(iOS 15.0, *)
    public static func randomImage(
        seed: String = Int.random(in: 1...100).formatted(),
        width: Int = 200,
        height: Int = 300
    ) -> URL {
        return URL(string: "https://picsum.photos/id/\(seed)/\(width)/\(height)")!
    }
}
