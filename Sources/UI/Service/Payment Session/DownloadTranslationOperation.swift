import Foundation

final class DownloadTranslationOperation: SendRequestOperation<DownloadLocalization> {
    let network: ApplicableNetwork
    
    init(for network: ApplicableNetwork, using connection: Connection) throws {
        guard let localizationURL = network.links?["lang"] else {
            let noLangUrlError = InternalError(description: "Applicable network doesn't contain localization URL. Network: %@", objects: network)
            throw noLangUrlError
        }
        
        self.network = network
        
        let downloadRequest = DownloadLocalization(from: localizationURL)
        super.init(connection: connection, request: downloadRequest)
    }
}
