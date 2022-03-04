// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

@objc public final class RiskProviderRegistry: NSObject {
    public private(set) var registeredProviders = [RiskProvider.Type]()

    public override init() {
        super.init()
    }

    public func register(provider: RiskProvider.Type) {
        registeredProviders.append(provider)
    }
}
