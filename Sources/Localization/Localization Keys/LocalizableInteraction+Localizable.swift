import Foundation

extension LocalizableInteraction: Localizable {
    var localizableFields: [LocalizationKey<LocalizableInteraction>] {
        return [
            .init(keyPath: \.localizedDescription, key: code + "." + reason)
        ]
    }
}
