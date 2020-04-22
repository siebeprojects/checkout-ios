import Foundation

struct IBANFormatProcessor: TextFormatProcessor {
    private let separator = " "
    private let groupSize = 4

    func format(string: String) -> String {
        let setWithNumberSeparator = CharacterSet.init(charactersIn: separator)

        var formattedText = string.remove(charactersIn: setWithNumberSeparator)
        
        formattedText = formattedText.uppercased()
        
        formattedText.insert(separator: separator, every: groupSize)
        formattedText = formattedText.trimmingCharacters(in: setWithNumberSeparator)

        return formattedText
    }
}
