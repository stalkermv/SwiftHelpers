//
//  Created by Valeriy Malishevskyi on 07.03.2024.
//

import Foundation

public extension String {
    static func random(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
    static func randomWord() -> String {
        let words = [
            "lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit", "sed", "do", "eiusmod", "tempor", "incididunt", "ut", "labore", "et", "dolore", "magna", "aliqua", "enim", "ad", "minim", "veniam", "quis", "nostrud", "exercitation", "ullamco", "laboris", "nisi", "ut", "aliquip", "ex", "ea", "commodo", "consequat", "duis", "aute", "irure", "dolor", "in", "reprehenderit", "in", "voluptate", "velit", "esse", "cillum", "dolore", "eu", "fugiat", "nulla", "pariatur", "excepteur", "sint", "occaecat", "cupidatat", "non", "proident", "sunt", "in", "culpa", "qui", "officia", "deserunt", "mollit", "anim", "id", "est", "laborum"
        ]
        return words.randomElement()!
    }
    
    static func randomSentence() -> String {
        return (0..<Int.random(in: 5...15)).map { _ in randomWord() }.joined(separator: " ").capitalized
    }
    
    static func randomParagraph() -> String {
        return (0..<Int.random(in: 3...7)).map { _ in randomSentence() }.joined(separator: ". ") + "."
    }
    
    static func randomLorem() -> String {
        return (0..<Int.random(in: 3...7)).map { _ in randomParagraph() }.joined(separator: "\n\n")
    }
    
    static func randomLorem(_ length: Int) -> String {
        return (0..<length).map { _ in randomParagraph() }.joined(separator: "\n\n")
    }
    
    static func randomLorem(sentences count: Int) -> String {
        return (0..<count).map { _ in randomSentence() }.joined(separator: ". ") + "."
    }
    
    static func randomLorem(words count: Int) -> String {
        return (0..<count).map { _ in randomWord() }.joined(separator: " ")
    }
    
    static func randomLorem(paragraphs count: Int) -> String {
        return (0..<count).map { _ in randomParagraph() }.joined(separator: "\n\n")
    }
}
