import Foundation

final class RegisteredAccount {
    private let apiModel: AccountRegistration
    let translation: TranslationProvider

    let label: String
    var logo: Loadable<Data>?
    
    init(from apiModel: AccountRegistration, localizeUsing localizer: TranslationProvider) {
        self.apiModel = apiModel
        self.translation = localizer
        
        self.label = localizer.translation(forKey: "network.label")
        
        if let logoURL = apiModel.links["logo"] {
            logo = .notLoaded(logoURL)
        } else {
            logo = nil
        }
    }

}
