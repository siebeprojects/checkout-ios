import Foundation

struct CardFormatProcessor: TextFormatProcessor {
    private let separator: String = " "
    private let groupSize = 4
    
    private let setWithSeparator: CharacterSet

    init() {
        setWithSeparator = CharacterSet(charactersIn: separator)
    }
    
    func format(string: String) -> String {
        var formattedText = string
        formattedText.insert(separator: separator, every: groupSize)
        formattedText = formattedText.trimmingCharacters(in: setWithSeparator)

        return formattedText
    }
    
    func clear(formattingFromString formattedString: String) -> String {
        return formattedString.remove(charactersIn: setWithSeparator)
    }
}
