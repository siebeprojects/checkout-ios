// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension List.Table {
    class DetailedHeaderView: UITableViewHeaderFooterView, Dequeueable {
        weak private(set) var primaryLabel: UILabel!
        weak private(set) var secondaryLabel: UILabel!

        override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)
            contentView.preservesSuperviewLayoutMargins = true
            addSubviews()
            addConstraints()
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func addSubviews() {
            let primaryLabel = UILabel(frame: .zero)
            self.primaryLabel = primaryLabel
            primaryLabel.font = UIFont.preferredThemeFont(forTextStyle: .footnote)

            let secondaryLabel = UILabel(frame: .zero)
            self.secondaryLabel = secondaryLabel
            secondaryLabel.font = UIFont.preferredFont(forTextStyle: .caption2).withWeight(.light)

            for label in [primaryLabel, secondaryLabel] {
                label.numberOfLines = 0
                label.textColor = Theme.shared.textColor

                label.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(label)
            }
        }

        func addConstraints() {
            var constraints = [NSLayoutConstraint]()

            // Add Y constraints
            constraints += [
                primaryLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
                secondaryLabel.topAnchor.constraint(equalTo: primaryLabel.bottomAnchor, constant: .verticalPadding),
                secondaryLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
            ]

            // Add X constraints
            for view in ([primaryLabel, secondaryLabel] as [UIView]) {
                constraints += [
                    view.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
                ]
            }

            NSLayoutConstraint.activate(constraints)
        }
    }
}

private extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let newDescriptor = fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: weight]
        ])
        return UIFont(descriptor: newDescriptor, size: pointSize)
    }
}

private extension CGFloat {
    /// Vertical padding after a footer view
    static var verticalPadding: CGFloat { return 8 }
}
