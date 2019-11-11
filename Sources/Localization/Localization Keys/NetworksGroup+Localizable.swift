import Foundation

extension NetworkGroup: Localizable {
    var localizableFields: [LocalizationKey<NetworkGroup>] {
        return [
            .init(keyPath: \.title, key: LocalTranslation.listHeaderNetworks.rawValue)
        ]
    }
}
