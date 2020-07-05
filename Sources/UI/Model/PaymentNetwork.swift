import Foundation

final class PaymentNetwork {
    let applicableNetwork: ApplicableNetwork
    let translation: TranslationProvider

    let label: String
    let submitButtonLabel: String
    var logo: Loadable<UIImage>?

    init(from applicableNetwork: ApplicableNetwork, submitButtonLocalizationKey: String, localizeUsing localizer: TranslationProvider) {
        self.applicableNetwork = applicableNetwork
        self.translation = localizer

        self.label = localizer.translation(forKey: "network.label")
        self.submitButtonLabel = translation.translation(forKey: submitButtonLocalizationKey)

        logo = Loadable<UIImage>(identifier: applicableNetwork.code.lowercased(), url: applicableNetwork.links?["logo"])
    }
}

enum Loadable<T> {
    case loaded(Result<T, Error>)
    case notLoaded(URL)

    var value: T? {
        guard case let .loaded(loadedResult) = self else { return nil }

        return try? loadedResult.get()
    }
}

private extension Loadable where T == UIImage {
    /// Initialize loadable image object, it will be set to `.loaded` if local asset with such identifier exists. Returns `nil` if no local asset was found and URL wasn't specified.
    init?(identifier: String, url: URL?) {
        let bundle = Bundle(for: PaymentNetwork.self)
        if let image = UIImage(named: identifier, in: bundle, compatibleWith: nil) {
            self = .loaded(.success(image))
            return
        }
        
        if let url = url {
            self = .notLoaded(url)
        } else {
            return nil
        }
    }
}

extension PaymentNetwork: Equatable, Hashable {
    public static func == (lhs: PaymentNetwork, rhs: PaymentNetwork) -> Bool {
        return (lhs.applicableNetwork.code == rhs.applicableNetwork.code)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(applicableNetwork.code)
    }
}

#if canImport(UIKit)
import UIKit

extension Loadable where T == Data {
    var image: UIImage? {
        guard let data = value else { return nil }
        return UIImage(data: data)
    }
}
#endif
