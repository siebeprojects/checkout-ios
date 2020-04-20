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

private extension Collection {
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}

private extension StringProtocol where Self: RangeReplaceableCollection {
    mutating func insert<S: StringProtocol>(separator: S, every n: Int) {
        for index in indices.dropFirst().reversed()
            where distance(to: index).isMultiple(of: n) {
            insert(contentsOf: separator, at: index)
        }
    }
    func inserting<S: StringProtocol>(separator: S, every n: Int) -> Self {
        var string = self
        string.insert(separator: separator, every: n)
        return string
    }
}
