import Foundation

final class RegisteredAccount {
    let apiModel: AccountRegistration
    let translation: TranslationProvider

    let networkLabel: String
    var logo: Loadable<Data>?
    
    init(from apiModel: AccountRegistration, localizeUsing localizer: TranslationProvider) {
        self.apiModel = apiModel
        self.translation = localizer
        
        self.networkLabel = localizer.translation(forKey: "network.label")
        
        if let logoURL = apiModel.links["logo"] {
            logo = .notLoaded(logoURL)
        } else {
            logo = nil
        }
    }

}
