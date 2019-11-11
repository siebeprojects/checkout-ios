import Foundation

struct PaymentNetwork {
    let code: String
    var label: String
    var logo: Logo?

    init(from applicableNetwork: ApplicableNetwork) {
        self.code = applicableNetwork.code
        self.label = String()
        
        if let logoURL = applicableNetwork.links?["logo"] {
            logo = Logo(url: logoURL)
        } else {
            logo = nil
        }
    }
}

extension PaymentNetwork {
    struct Logo {
        var data: Data? = nil
        let url: URL
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
