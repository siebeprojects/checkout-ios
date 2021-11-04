// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension CALayer {
    func setBorderColor(_ color: UIColor, animated: Bool) {
        if animated {
            let animation = CABasicAnimation(keyPath: "borderColor")
            animation.fromValue = borderColor
            animation.toValue = color.cgColor
            animation.duration = Constants.defaultAnimationDuration
            borderColor = color.cgColor
            add(animation, forKey: "borderColor")
        } else {
            borderColor = color.cgColor
        }
    }
}
