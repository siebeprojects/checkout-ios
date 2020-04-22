import Foundation

struct CardFormatProcessor: TextFormatProcessor {
    private let cardNumberSeparator = " "
    private let groupSize = 4

    func format(string: String) -> String {
        let setWithNumberSeparator = CharacterSet.init(charactersIn: cardNumberSeparator)

        var formattedText = string.remove(charactersIn: setWithNumberSeparator)
        formattedText.insert(separator: cardNumberSeparator, every: groupSize)
        formattedText = formattedText.trimmingCharacters(in: setWithNumberSeparator)

        return formattedText
    }
}
