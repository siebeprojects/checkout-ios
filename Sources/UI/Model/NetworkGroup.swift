import Foundation

final class NetworkGroup {
    let title: String
    let networks: [PaymentNetwork]
    
    init(networks: [PaymentNetwork], localizeUsing localizer: TranslationProvider) {
        self.title = localizer.translation(forKey: LocalTranslation.listHeaderNetworks.rawValue)
        self.networks = networks
    }
}
