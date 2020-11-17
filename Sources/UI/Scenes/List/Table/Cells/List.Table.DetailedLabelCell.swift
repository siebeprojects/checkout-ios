// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

#if canImport(UIKit)
import Foundation
import UIKit

extension List.Table {
    /// Cell with multiple images, primary and secondary labels.
    /// - Note: set `cellIndex`
    final class DetailedLabelCell: List.Table.BorderedCell, DequeueableCell {
        weak var primaryLabel: UILabel?
        weak var secondaryLabel: UILabel?
        weak var logoView: UIImageView?

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            addContentViews()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - Content views

extension List.Table.DetailedLabelCell {
    fileprivate func addContentViews() {
        let primaryLabel = UILabel(frame: .zero)
        primaryLabel.translatesAutoresizingMaskIntoConstraints = false
        primaryLabel.font = UIFont.preferredThemeFont(forTextStyle: .body)
        primaryLabel.textColor = .themedText
        contentView.addSubview(primaryLabel)
        self.primaryLabel = primaryLabel

        let secondaryLabel = UILabel(frame: .zero)
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryLabel.font = UIFont.preferredThemeFont(forTextStyle: .footnote)
        secondaryLabel.textColor = .themedDetailedText
        contentView.addSubview(secondaryLabel)
        self.secondaryLabel = secondaryLabel

        let logoView = UIImageView(frame: .zero)
        logoView.tintColor = .themedDetailedText
        logoView.contentMode = .scaleAspectFill
        logoView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(logoView)
        self.logoView = logoView

        // Layout

        NSLayoutConstraint.activate([
            primaryLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: .labelToLeftSeparatorSpacing),
            primaryLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.topAnchor),
            primaryLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor, constant: .verticalSpacing / -2),
            primaryLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

            secondaryLabel.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: .defaultSpacing * 2),
            secondaryLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: .verticalSpacing / 2),
            secondaryLabel.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor),
            secondaryLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

            logoView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            logoView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            logoView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            logoView.trailingAnchor.constraint(equalTo: primaryLabel.leadingAnchor, constant: -2 * CGFloat.defaultSpacing)
        ])
    }
}

// MARK: - Constants

private extension CGFloat {
    static var labelToLeftSeparatorSpacing: CGFloat { return 68 }
    static var defaultSpacing: CGFloat { return 8 }
    static var verticalSpacing: CGFloat { return 4 }
}
#endif
