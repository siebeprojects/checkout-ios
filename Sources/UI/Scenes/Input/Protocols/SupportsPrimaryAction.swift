// Copyright (c) 2020–2021 Payoneer Germany GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

protocol SupportsPrimaryAction {
    func setPrimaryAction(to action: PrimaryAction)
}

enum PrimaryAction {
    case next, done
}
