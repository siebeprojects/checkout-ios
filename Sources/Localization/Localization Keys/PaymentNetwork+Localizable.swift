import Foundation

extension PaymentNetwork: Localizable {
    var localizableFields: [LocalizationKey<PaymentNetwork>] {
        return [
            .init(keyPath: \.label, key: "network.label")
        ]
    }
}
