import Foundation

struct LocalizableError {
    private(set) var localizedDescription: String = String()
    var localizationKey: LocalTranslation
    var underlyingError: Error?
}

extension LocalizableError: Localizable {
    var localeURL: URL? { return nil }

    var localizableFields: [LocalizationKey<LocalizableError>] {
        [
            .init(keyPath: \.localizedDescription, key: localizationKey.rawValue)
        ]
    }
}
