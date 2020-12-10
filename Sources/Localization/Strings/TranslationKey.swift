// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

// TODO: Should be moved to a local json file
enum TranslationKey: String, CaseIterable {
    case errorTitle = "messages.error.default.title"
    case errorText = "messages.error.default.text"
    
    case errorInternetTitle = "messages.error.internet.title"
    case errorInternetText = "messages.error.internet.text"

    case cancelLabel = "button.cancel.label"
    case retryLabel = "button.retry.label"
    case okLabel = "button.ok.label"

    var localizedString: String {
        switch self {
        case .errorTitle: return "Oops!"
        case .errorText: return "An error occurred while handling your payment. Please try again."
        case .errorInternetTitle: return "Oops!"
        case .errorInternetText: return "There was a problem with your internet connection"
        case .retryLabel: return "Retry"
        case .cancelLabel: return "Cancel"
        case .okLabel: return "OK"
        }
    }
}
