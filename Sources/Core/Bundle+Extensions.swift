// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

extension Bundle {
    /// Returns `module` when the SDK is being imported via SPM. Returns a local-class bundle when being used through other ways (e.g. CocoaPods).
    static var current: Bundle {
#if SWIFT_PACKAGE
        return .module
#else
        return .init(for: AssetProvider.self)
#endif
    }

    var frameworkIdentifier: String {
        return bundleIdentifier ?? "com.payoneer.checkout"
    }
}
