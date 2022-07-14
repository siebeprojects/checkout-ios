// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

public class Form: NSObject {
    public init(inputFields: [String: String], autoRegistration: Bool?, allowRecurrence: Bool?) {
        self.inputFields = inputFields
        self.autoRegistration = autoRegistration
        self.allowRecurrence = allowRecurrence
    }

    public let inputFields: [String: String]
    public let autoRegistration: Bool?
    public let allowRecurrence: Bool?
}
