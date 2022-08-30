// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking

extension UIModel {
    final class PaymentNetwork {
        let applicableNetwork: ApplicableNetwork
        let translation: TranslationProvider

        let label: String
        let submitButtonLocalizableText: Localizable
        var logo: Loadable<UIImage>?

        init(from applicableNetwork: ApplicableNetwork, submitButtonLocalizableText: Localizable, localizeUsing localizer: TranslationProvider) {
            self.applicableNetwork = applicableNetwork
            self.translation = localizer

            self.label = localizer.translation(forKey: "network.label")
            self.submitButtonLocalizableText = submitButtonLocalizableText

            logo = Loadable<UIImage>(identifier: applicableNetwork.code.lowercased(), url: applicableNetwork.links?["logo"])
        }
    }
}

extension UIModel.PaymentNetwork: Equatable, Hashable {
    public static func == (lhs: UIModel.PaymentNetwork, rhs: UIModel.PaymentNetwork) -> Bool {
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
