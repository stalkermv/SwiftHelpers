//
//  Created by Valeriy Malishevskyi on 14.09.2022.
//

import Foundation

public extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}

public extension Sequence {
    func unique<T: Hashable>(by taggingHandler: (_ element: Self.Iterator.Element) -> T) -> [Self.Iterator.Element] {
        var knownTags = Set<T>()
        
        return self.filter { element -> Bool in
            let tag = taggingHandler(element)
            
            if !knownTags.contains(tag) {
                knownTags.insert(tag)
                return true
            }
            
            return false
        }
    }
}
