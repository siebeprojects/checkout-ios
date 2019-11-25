import Foundation

/// Translation provider that is used to combine multiple translations
class CombinedTranslationProvider {
    private let priorityTranslation: [String: String]
    private let otherProvider: TranslationProvider
    
    init(priorityTranslation: Dictionary<String, String>, otherProvider: TranslationProvider) {
        self.otherProvider = otherProvider
        self.priorityTranslation = priorityTranslation
    }
}

extension CombinedTranslationProvider: TranslationProvider {
    var translations: [[String: String]] {
        var resultingArray = [priorityTranslation]
        resultingArray.append(contentsOf: otherProvider.translations)
        return resultingArray
    }
}
