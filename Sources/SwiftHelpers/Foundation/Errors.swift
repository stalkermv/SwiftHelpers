//
//  Created by Valeriy Malishevskyi on 25.07.2022.
//

import Foundation

public struct SomeError: LocalizedError {
    
    public init() {}
    
    public var errorDescription: String? {
        return NSLocalizedString("Some error occurred. Please try again later", comment: "Some error occurred")
    }
}

public struct CustomError: LocalizedError {
    var text: String?
    
    public init(text: String?) {
        self.text = text
    }
    
    public var errorDescription: String? {
        return text ?? ""
    }
}
