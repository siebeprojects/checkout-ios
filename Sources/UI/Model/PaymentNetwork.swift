import Foundation

final class PaymentNetwork {
    let code: String
    let label: String
    let logo: Logo?

    init(from applicableNetwork: ApplicableNetwork, localizeUsing localizer: TranslationProvider) {
        self.code = applicableNetwork.code
        self.label = localizer.translation(forKey: "network.label")
        
        if let logoURL = applicableNetwork.links?["logo"] {
            logo = Logo(url: logoURL)
        } else {
            logo = nil
        }
    }
}

extension PaymentNetwork {
    final class Logo {
        var data: Data? = nil
        let url: URL
        
        init(url: URL) {
            self.url = url
        }
    }
}

extension PaymentNetwork: Equatable, Hashable {
    public static func == (lhs: PaymentNetwork, rhs: PaymentNetwork) -> Bool {
        return (lhs.code == rhs.code)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
}
