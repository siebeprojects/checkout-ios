// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking

struct ListResultNetworks {
    let listResult: ListResult
    let filteredNetworks: FilteredNetworks

    struct FilteredNetworks {
        let applicableNetworks: [ApplicableNetwork]
        let accountRegistrations: [AccountRegistration]
        let presetAccount: PresetAccount?
    }
}
