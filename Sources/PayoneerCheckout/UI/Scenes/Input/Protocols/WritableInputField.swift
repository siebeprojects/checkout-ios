// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

/// Same as `InputField` but value could be changed
protocol WritableInputField: InputField {
    var value: String { get set }
}
