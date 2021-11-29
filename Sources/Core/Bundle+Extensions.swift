// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

extension Bundle {
    /// Returns `module` if the SDK is imported via Swift Package Manager, otherwise returns `main` if imported through other means (e.g. CocoaPods).
    static var current: Bundle {
#if SWIFT_PACKAGE
        return .module
#else
        return .main
#endif
    }

    var frameworkIdentifier: String {
        return self.bundleIdentifier ?? "com.payoneer.checkout"
    }
}
