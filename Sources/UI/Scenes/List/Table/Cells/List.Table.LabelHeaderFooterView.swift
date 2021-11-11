// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension List.Table {
    class LabelHeaderFooterView: UITableViewHeaderFooterView, Dequeueable {
        weak var label: UILabel?
        private weak var spacer: UIView?

        override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)
            let labelView = addLabelView()
            self.label = labelView

            let spacerView = addSpacerView(withTopAnchor: labelView.bottomAnchor)
            self.spacer = spacerView
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        @discardableResult
        private func addLabelView() -> UILabel {
            let label = UILabel(frame: .zero)
            label.numberOfLines = 0
            label.font = UIFont.preferredFont(forTextStyle: .caption2).withWeight(.light)
            label.textColor = Theme.shared.textColor

            contentView.addSubview(label)

            label.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
                label.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            ])

            return label
        }

        private func addSpacerView(withTopAnchor topAnchor: NSLayoutYAxisAnchor) -> UIView {
            let spacer = UIView(frame: .zero)
            contentView.addSubview(spacer)

            spacer.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                spacer.topAnchor.constraint(equalTo: topAnchor),
                spacer.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
                spacer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                spacer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                spacer.heightAnchor.constraint(equalToConstant: .verticalPadding)
            ])

            return spacer
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
