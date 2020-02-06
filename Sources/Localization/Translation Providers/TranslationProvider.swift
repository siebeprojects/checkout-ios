import Foundation

protocol TranslationProvider {
    var translations: [[String: String]] { get }
    
    func translation(forKey key: String) -> String
    func translation(forKey key: String) -> String?
}

extension TranslationProvider {
    /// Find a translation for a key
    /// - Returns: translation or key if translation wasn't found
    func translation(forKey key: String) -> String {
        if let translation = translation(forKey: key) {
            return translation
        } else {
            log(.error, "Localization for key %@ is not found", key)
            return String()
        }
    }
    
    /// Find a translation for a key
    /// - Returns: translation or `nil` if translation wasn't found
    func translation(forKey key: String) -> String? {
        for dictionary in translations {
            guard let translation = dictionary[key] else { continue }
            return translation
        }

        return nil
    }
}
