// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

public class ProviderParameters: NSObject, Decodable {
    /// The code of payment provider
    let providerCode: String

    /// An array of parameters
    let parameters: [Parameter]
}
