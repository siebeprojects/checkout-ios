// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

/// Generic UI model for input element
protocol InputField: AnyObject {
    var id: Input.Field.Identifier { get }
    var value: String { get }
}

extension InputField where Self: InputElementModel {
    var id: Input.Field.Identifier { .inputElementName(inputElement.name) }
}
