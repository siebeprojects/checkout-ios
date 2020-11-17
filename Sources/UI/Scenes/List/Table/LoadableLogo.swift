// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

/// Model that contains loadable logo
protocol LoadableLogo: class {
    var logo: Loadable<UIImage>? { get set }
}
