//
//  Created by Valeriy Malishevskyi on 17.01.2024.
//

import Foundation

@resultBuilder
public enum ArrayBuilder<OutputModel> {
    public static func buildEither(first component: [OutputModel]) -> [OutputModel] {
        return component
    }
    
    public static func buildEither(second component: [OutputModel]) -> [OutputModel] {
        return component
    }
    
    public static func buildOptional(_ component: [OutputModel]?) -> [OutputModel] {
        return component ?? []
    }
    
    public static func buildExpression(_ expression: OutputModel) -> [OutputModel] {
        return [expression]
    }
    
    public static func buildExpression(_ expression: ()) -> [OutputModel] {
        return []
    }
    
    public static func buildBlock(_ components: [OutputModel]...) -> [OutputModel] {
        return components.flatMap { $0 }
    }
    
    public static func buildArray(_ components: [[OutputModel]]) -> [OutputModel] {
        Array(components.joined())
    }
}
