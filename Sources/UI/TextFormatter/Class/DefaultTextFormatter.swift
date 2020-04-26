// Based on https://github.com/luximetr/AnyFormatKit (MIT License)
// Based on commit: fe937c1e83574ad66f87f4a3eedc592440304077

import Foundation

class DefaultTextFormatter: TextFormatter {
    /// String, that will use for formatting of string replacing patter symbol, example: patternSymbol - "#", format - "### (###) ###-##-##"
    let textPattern: String

    /// Symbol that will be replace by input symbols
    let patternSymbol: Character

    /// - Parameters:
    ///   - textPattern: example: `## ## ## #`
    ///   - patternSymbol: character, that will be replaced by input characters in textPattern
    init(textPattern: String, patternSymbol: Character) {
        self.textPattern = textPattern
        self.patternSymbol = patternSymbol
    }

    /// Formatting text with current textPattern
    /// - Parameter unformattedText: String, that need to be convert with current textPattern
    /// - Returns: formatted text with current textPattern
    func format(_ unformattedText: String, addTrailingPattern: Bool) -> String {
        var formatted = String()
        var unformattedIndex = 0
        var patternIndex = 0

        while patternIndex < textPattern.count {
            guard let patternCharacter = textPattern.characterAt(patternIndex) else { break }

            if unformattedIndex < unformattedText.count {
                if patternCharacter == patternSymbol {
                    if let unformattedCharacter = unformattedText.characterAt(unformattedIndex) {
                        formatted.append(unformattedCharacter)
                    }
                    unformattedIndex += 1
                } else {
                    formatted.append(patternCharacter)
                }
            } else {
                guard addTrailingPattern else { break }
                guard patternCharacter != patternSymbol else { break }
                formatted.append(patternCharacter)
            }

            patternIndex += 1
        }

        return formatted
    }

    func unformat(_ formatted: String) -> String {
        let patternSymbolCharacterSet = CharacterSet(charactersIn: String(patternSymbol))
        let charactersToRemove = textPattern.remove(charactersIn: patternSymbolCharacterSet)
        let setToRemove = CharacterSet(charactersIn: charactersToRemove)

        return formatted.remove(charactersIn: setToRemove)
    }
}
