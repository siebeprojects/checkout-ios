// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

// TODO: Should be moved to a local json file
enum TranslationKey: String, CaseIterable {
    case errorInternetTitle = "messages.error.internet.title"
    case errorInternetText = "messages.error.internet.text"

    case cancelLabel = "button.cancel.label"
    case retryLabel = "button.retry.label"

    case accountsUpdateTitle = "accounts.update.title"
    case networksUpdateTitle = "networks.update.title"

    // Used in UPDATE flow
    case processPendingTitle = "interaction.PROCEED.PENDING.title"
    case processPendingText = "interaction.PROCEED.PENDING.text"

    case accountsExpiredBadgeTitle = "accounts.expired.badge.title"
    case accountsExpiredBadgeText = "accounts.expired.badge.text"

    case messagesCheckboxForcedTitle = "messages.checkbox.forced.title"
    case messagesCheckboxForcedText = "messages.checkbox.forced.text"

    var localizedString: String {
        switch self {
        case .errorInternetTitle: return "Oops!"
        case .errorInternetText: return "There was a problem with your internet connection."
        case .retryLabel: return "Retry"
        case .cancelLabel: return "Cancel"
        case .accountsUpdateTitle: return "Edit your payment methods"
        case .networksUpdateTitle: return "Add a payment method"
        case .processPendingTitle: return "Payment method pending"
        case .processPendingText: return "Please refresh or check back later for updates."
        case .accountsExpiredBadgeTitle: return "Expired"
        case .accountsExpiredBadgeText: return "This card is expired. Please update it or use another payment method."
        case .messagesCheckboxForcedTitle: return "Oops!"
        case .messagesCheckboxForcedText: return "This is a mandatory agreement and cannot be unselected."
        }
    }
}
