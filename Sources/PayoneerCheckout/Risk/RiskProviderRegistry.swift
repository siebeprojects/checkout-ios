// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Risk

/// Registry for all risk providers.
@objc public final class RiskProviderRegistry: NSObject {
    public private(set) var registeredProviders = [RiskProvider.Type]()

    /// You shouldn't initialize this class by yourself.
    public override init() {
        super.init()
    }

    /// Register a risk provider.
    public func register(provider: RiskProvider.Type) {
        registeredProviders.append(provider)
    }

    /// Register a risk provider (type-erased method).
    /// - Important: Use this method with Objective-C, in Swift you should use `register(provider:)` method.
    /// - Parameter anyProvider: should conform to `RiskProvider` type, if not error will be thrown
    @objc public func register(anyProvider: AnyClass) throws {
        guard let provider = anyProvider as? RiskProvider.Type else {
            throw NSError(
                domain: "com.payoneer.checkout",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Please provide an argument conforming to RiskProvider type"])
        }
        registeredProviders.append(provider)
    }
}
