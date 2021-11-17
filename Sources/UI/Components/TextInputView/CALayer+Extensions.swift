// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension CALayer {
    func setBorderColor(_ color: UIColor, animated: Bool) {
        guard animated else {
            borderColor = color.cgColor
            return
        }

        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = borderColor
        animation.toValue = color.cgColor
        animation.duration = animationDuration
        borderColor = color.cgColor
        add(animation, forKey: "borderColor")
    }

    func setBorderWidth(_ width: CGFloat, animated: Bool) {
        guard animated else {
            borderWidth = width
            return
        }

        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.fromValue = borderWidth
        animation.toValue = width
        animation.duration = animationDuration
        borderWidth = width
        add(animation, forKey: "borderWidth")
    }
}
