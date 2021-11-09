// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension List.Table {
    class LabelHeaderFooterView: UITableViewHeaderFooterView, Dequeueable {
        weak var label: UILabel?

        override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)
            addLabelView()
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func addLabelView() {
            let label = UILabel(frame: .zero)
            label.numberOfLines = 0
            label.font = UIFont.preferredFont(forTextStyle: .caption2).withWeight(.light)
            label.textColor = Theme.shared.textColor

            contentView.addSubview(label)

            label.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
                label.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
                label.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            ])

            self.label = label
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
