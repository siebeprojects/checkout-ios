import Foundation

struct IBANFormatProcessor: TextFormatProcessor {
    private let separator: Character = " "
    private let separatorPosition = 2

    func format(string: String) -> String {
        guard string.count > 2 else { return string }

        var modifiedString = clearFormat(in: string)
        let insertPosition = modifiedString.index(modifiedString.startIndex, offsetBy: separatorPosition)
        modifiedString.insert(separator, at: insertPosition)

        return modifiedString
    }

    private func clearFormat(in string: String) -> String {
        let setWithSeparator = CharacterSet(charactersIn: String(separator))
        return string.remove(charactersIn: setWithSeparator)
    }
}
