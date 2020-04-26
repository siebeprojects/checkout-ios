// Based on https://github.com/luximetr/AnyFormatKit (MIT License)
// Based on commit: fe937c1e83574ad66f87f4a3eedc592440304077

import Foundation

class DefaultTextInputFormatter: DefaultTextFormatter, TextInputFormatter {

    private let caretPositionCorrector: CaretPositionCorrector

    /// - Parameters:
    ///   - textPattern: string with special characters, that will be used for formatting (e.g. `### ##`)
    ///   - patternSymbol: parameter, that represent character, that will be replaced in formatted string
    override init(textPattern: String, patternSymbol: Character) {
        self.caretPositionCorrector = CaretPositionCorrector(textPattern: textPattern, patternSymbol: patternSymbol)
        super.init(textPattern: textPattern, patternSymbol: patternSymbol)
    }

    func formatInput(currentText: String, range: NSRange, replacementString text: String) -> FormattedTextValue {
        let unformattedRange = self.unformattedRange(from: range)
        let oldUnformattedText = unformat(currentText) as NSString

        let newText = oldUnformattedText.replacingCharacters(in: unformattedRange, with: unformat(text))
        let formattedText = self.format(newText)

        let caretOffset = getCorrectedCaretPosition(range: range, replacementString: text)

        return FormattedTextValue(formattedText: formattedText, caretBeginOffset: caretOffset)
    }
}

private extension DefaultTextInputFormatter {
    /// Convert range in formatted string to range in unformatted string
    /// - Parameter range: range in formatted (with current textPattern) string
    /// - Returns: range in unformatted (with current textPattern) string
    func unformattedRange(from range: NSRange) -> NSRange {
        let newRange = NSRange(
            location: range.location - textPattern[..<textPattern.index(textPattern.startIndex, offsetBy: range.location)]
                .replacingOccurrences(of: String(patternSymbol), with: "").count,
            length: range.length - (textPattern as NSString).substring(with: range)
                .replacingOccurrences(of: String(patternSymbol), with: "").count)
        return newRange
    }

    private func getCorrectedCaretPosition(range: NSRange, replacementString: String) -> Int {
        let offset = caretPositionCorrector.calculateCaretPositionOffset(originalRange: range, replacementFiltered: replacementString)
        return offset
    }
}
