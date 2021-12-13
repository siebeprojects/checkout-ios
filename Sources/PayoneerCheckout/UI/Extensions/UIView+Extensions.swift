// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

// MARK: - Animation

let animationDuration: TimeInterval = 0.3

extension UIView {
    func animate(_ animations: @escaping () -> Void, completion: @escaping () -> Void = {}) {
        animate(withDuration: animationDuration, animations: animations, completion: completion)
    }

    func animate(
        withDuration duration: TimeInterval,
        after: TimeInterval = 0,
        animations: @escaping () -> Void,
        completion: @escaping () -> Void = {}
    ) {
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: animations)
        animator.addCompletion { _ in completion() }
        animator.startAnimation(afterDelay: after)
    }
}

// MARK: - Auto Layout

extension UIView {
    func addWidthConstraint(_ value: CGFloat) {
        addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: .width,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: value
            )
        )
    }

    func addHeightConstraint(_ value: CGFloat) {
        addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: value
            )
        )
    }

    func fitVerticalEdgesToSuperview(obeyMargins: Bool = false) {
        superview?.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: obeyMargins ? "V:|-[view]-|" : "V:|[view]|",
                options: [],
                metrics: nil,
                views: ["view": self]
            )
        )
    }

    func fitHorizontalEdgesToSuperview(obeyMargins: Bool = false) {
        superview?.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: obeyMargins ? "H:|-[view]-|" : "H:|[view]|",
                options: [],
                metrics: nil,
                views: ["view": self]
            )
        )
    }

    func fitToSuperview(obeyMargins: Bool = false) {
        fitVerticalEdgesToSuperview(obeyMargins: obeyMargins)
        fitHorizontalEdgesToSuperview(obeyMargins: obeyMargins)
    }

    func centerHorizontallyInSuperview() {
        superview?.addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: superview,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            )
        )
    }

    func centerVerticallyInSuperview() {
        superview?.addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: superview,
                attribute: .centerY,
                multiplier: 1,
                constant: 0
            )
        )
    }

    func centerInSuperview() {
        centerHorizontallyInSuperview()
        centerVerticallyInSuperview()
    }
}

// MARK: - Other

extension UIView {
    // Workaround for a bug in UIKit (http://www.openradar.me/25087688)
    var isHiddenInStackView: Bool {
        get {
            return isHidden
        }
        set {
            if isHidden != newValue {
                isHidden = newValue
            }
        }
    }
}
