// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

protocol CheckboxViewDelegate: AnyObject {
    func checkboxView(_ view: CheckboxView, valueDidChangeTo isOn: Bool)
}
