// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

public struct OperationData: Encodable {
    public var account: [String: String]?

    /// If set to `true` the account will be registered for further payments.
    public var autoRegistration: Bool?

    /// If set to `true` the account will be registered for further recurring payments.
    public var allowRecurrence: Bool?

    /// Map of selected checkboxes; name reflects the checkbox distinguish name, value reflects its state - `true` for selected, `false` for unchecked
    public var checkboxes: [String: Bool]?

    /// Provider request parameters which should be provided to the target payment provider adapter to complete the operation.
    public var providerRequest: ProviderParameters?

    /// List of provider request parameters which should be provided to the target payment provider adapter to complete the operation.
    public var providerRequests: [ProviderParameters]?

    /// Customer web browser data.
    internal var browserData: BrowserData?

    // Not used variables: style: ClientStyle
}
