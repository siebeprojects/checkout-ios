// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

struct TranslatedError: LocalizedError {
    var localizedDescription: String
    var underlyingError: Error?
    var errorDescription: String? { return localizedDescription}
}
