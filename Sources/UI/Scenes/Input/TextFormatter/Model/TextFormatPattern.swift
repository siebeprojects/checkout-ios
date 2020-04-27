import Foundation

struct TextFormatPattern {
    let textPattern: String
    let patternSymbol: Character

    init(textPattern: String, patternSymbol: Character = "#") {
        self.textPattern = textPattern
        self.patternSymbol = patternSymbol
    }
}
