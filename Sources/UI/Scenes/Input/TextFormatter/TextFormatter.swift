import UIKit

class TextFormatter {
    var processor: TextFormatProcessor

    init(processor: TextFormatProcessor) {
        self.processor = processor
    }

    func format(string currentString: String, shouldChangeCharactersIn range: NSRange, replacementString: String) -> FormattedString {
        let textRange = Range(range, in: currentString)!
        let replacedString = currentString.replacingCharacters(in: textRange, with: replacementString)

        let formattedString = processor.format(string: replacedString)

        // Calculate cursor offset
        let action: CursorOffsetLocator.Action = replacementString.isEmpty ? .delete : .insert
        let locator = CursorOffsetLocator(oldString: currentString, newString: formattedString, changesRangeBeforeFormatting: range, action: action)
        let newCursorOffset = locator.getNewCursorOffset()

        return FormattedString(formattedString: formattedString, cursorOffset: newCursorOffset)
    }
}

private struct CursorOffsetLocator {
    let oldString: String
    let newString: String
    let changesRangeBeforeFormatting: NSRange
    let action: Action

    enum Action {
        case insert, delete
    }

    func getNewCursorOffset() -> Int {
        switch action {
        // Characters were deleted
        case .delete:
            let newCursorPosition = changesRangeBeforeFormatting.lowerBound

            if newCursorPosition > newString.count {
                // If new position is outside string range (e.g. deleted five from "1234 5", new string will be "1234"
                return newString.count
            } else {
                return newCursorPosition
            }
        // Characters were inserted
        case .insert:
            let currentOffset = changesRangeBeforeFormatting.upperBound
            let newCursorOffset = currentOffset + newString.count - oldString.count
            return newCursorOffset
        }
    }
}

extension TextFormatter {
    struct FormattedString {
        let formattedString: String
        let cursorOffset: Int
    }
}

extension UITextField {
    func apply(formattedString: TextFormatter.FormattedString) {
        self.text = formattedString.formattedString
        let position = self.position(from: self.beginningOfDocument, offset: formattedString.cursorOffset)!
        let newTextRange = self.textRange(from: position, to: position)
        DispatchQueue.main.async {
            self.selectedTextRange = newTextRange
        }
    }
}

protocol TextFormatProcessor {
    func format(string: String) -> String
}
