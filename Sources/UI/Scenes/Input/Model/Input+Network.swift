import Foundation

extension Input {
    class Network {
        private let applicableNetwork: ApplicableNetwork
        let translation: TranslationProvider

        let label: String
        let logoData: Data?
        
        init(importFrom network: PaymentNetwork) {
            self.applicableNetwork = network.applicableNetwork
            self.translation = network.translation
            
            self.label = network.label
            
            // Was loading started? Was loading completed? Was it completed successfully?
            if case let .some(.loaded(.success(imageData))) = network.logo {
                self.logoData = imageData
            } else {
                self.logoData = nil
            }
        }
    }
}
