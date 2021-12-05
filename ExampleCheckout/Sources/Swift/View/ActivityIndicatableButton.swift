// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

class ActivityIndicatableButton: UIButton {
    /// Enables or disables activity indicator inside the button.
    var isLoading: Bool = false {
        didSet {
            setActivityIndicator(isAnimating: isLoading)
        }
    }

    private weak var activityIndicator: UIActivityIndicatorView?
    private var title: String?

    private func setActivityIndicator(isAnimating: Bool) {
        if isAnimating {
            super.setTitle(nil, for: .normal)

            let activityIndicator = UIActivityIndicatorView(style: .white)
            self.activityIndicator = activityIndicator
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            addSubview(activityIndicator)

            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])

            activityIndicator.startAnimating()
        } else {
            activityIndicator?.stopAnimating()
            activityIndicator?.removeFromSuperview()
            activityIndicator = nil

            super.setTitle(title, for: .normal)
        }
    }

    override func setTitle(_ title: String?, for state: UIControl.State) {
        self.title = title
        super.setTitle(title, for: state)
    }
}
