//
//  Created by Valeriy Malishevskyi on 25.07.2022.
//

import Foundation

public extension String {
    /// Evaluates the string against the provided regular expression pattern.
    ///
    /// This function returns `true` if the string matches the provided regex pattern, and `false` otherwise.
    ///
    /// - Parameter regex: The regular expression pattern to evaluate against the string.
    ///
    /// - Returns: A boolean value indicating whether the string matches the provided regex pattern.
    ///
    /// # Example
    /// ```
    /// let email = "example@email.com"
    /// let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
    ///
    /// let isValidEmail = email.evaluate(withRegex: emailRegex)
    /// // isValidEmail is true
    /// ```
    func evaluate(withRegex regex: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
}

// MARK: - Identifiable

extension String: Identifiable {
    public var id: String { self }
}

// MARK: - Base64

public extension String {
    func toBase64() -> String {
        Data(self.utf8).base64EncodedString()
    }
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
