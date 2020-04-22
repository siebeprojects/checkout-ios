import Foundation

struct IBANFormatProcessor: TextFormatProcessor {
    private let separator = " "
    private let groupSize = 4
    
    private let setWithSeparator: CharacterSet

    init() {
        setWithSeparator = CharacterSet(charactersIn: separator)
    }

    func format(string: String) -> String {
        var formattedText = string.uppercased()
        formattedText.insert(separator: separator, every: groupSize)
        formattedText = formattedText.trimmingCharacters(in: setWithSeparator)

        return formattedText
    }
    
    func clear(formattingFromString formattedString: String) -> String {
        return formattedString.remove(charactersIn: setWithSeparator)
    }
}
