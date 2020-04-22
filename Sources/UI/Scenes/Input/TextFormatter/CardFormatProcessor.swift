import Foundation

struct CardFormatProcessor: TextFormatProcessor {
    private let separator = " "
    private let groupSize = 4

    func format(string: String) -> String {
        let setWithNumberSeparator = CharacterSet.init(charactersIn: separator)

        var formattedText = string.remove(charactersIn: setWithNumberSeparator)
        formattedText.insert(separator: separator, every: groupSize)
        formattedText = formattedText.trimmingCharacters(in: setWithNumberSeparator)

        return formattedText
    }
}
