// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension List.Table {
    class LabelHeaderFooterView: UITableViewHeaderFooterView, Dequeueable {
        weak private(set) var label: UILabel!

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
            let label = UILabel(frame: .zero)
            self.label = label
            label.font = UIFont.preferredThemeFont(forTextStyle: .footnote)
            label.numberOfLines = 0
            label.textColor = Theme.shared.textColor
            label.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(label)
        }

        func addConstraints() {
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: contentView.topAnchor),
                label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
                label.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
            ])
        }
    }
}
