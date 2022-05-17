// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking

struct InteractionLocalizer {
    let translator: TranslationProvider

    private let globalPrefix = "interaction."

    func localize(interaction: Interaction) -> LocalizedInteraction? {
        if let localizableInteraction = interaction as? LocalizableInteraction {
            // Try to localize using flow prefix
            let keysWithFlow = localizationKeys(for: interaction, usingPrefix: globalPrefix + localizableInteraction.flow.localizationKey + ".")

            if let localizedInteraction = translate(using: keysWithFlow) {
                return localizedInteraction
            }

            // If flow localization failed try to use a generic approach
        }

        let keys = localizationKeys(for: interaction, usingPrefix: globalPrefix)
        return translate(using: keys)
    }

    private func translate(using keys: LocalizationKeys) -> LocalizedInteraction? {
        guard let title = translator.translation(forKey: keys.title), let message = translator.translation(forKey: keys.message) else {
            return nil
        }

        return LocalizedInteraction(title: title, message: message)
    }

    /// Get keys in format that is used in localization files for specified `Interaction`
    private func localizationKeys(for interaction: Interaction, usingPrefix prefix: String) -> LocalizationKeys {
        let prefixWithInteraction = prefix + interaction.code + "." + interaction.reason + "."

        let titleKey = prefixWithInteraction + "title"
        let messageKey = prefixWithInteraction + "text"

        return LocalizationKeys(title: titleKey, message: messageKey)
    }
}

extension InteractionLocalizer {
    fileprivate struct LocalizationKeys {
        let title: String
        let message: String
    }

    struct LocalizedInteraction {
        let title: String
        let message: String
    }
}

private extension Flow {
    var localizationKey: String { self.rawValue.uppercased() }
}
