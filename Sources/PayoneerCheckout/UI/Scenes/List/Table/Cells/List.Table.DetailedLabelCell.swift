// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

#if canImport(UIKit)
import Foundation
import UIKit

extension List.Table {
    /// Cell with multiple images, primary and secondary labels.
    /// - Note: set `cellIndex`
    final class DetailedLabelCell: List.Table.BorderedCell, Dequeueable {
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
        let primaryLabel = UILabel()
        primaryLabel.font = UIFont.preferredThemeFont(forTextStyle: .body)
        primaryLabel.textColor = .themedText
        self.primaryLabel = primaryLabel

        let secondaryLabel = UILabel()
        secondaryLabel.font = UIFont.preferredThemeFont(forTextStyle: .footnote)
        secondaryLabel.textColor = .themedDetailedText
        self.secondaryLabel = secondaryLabel

        let logoView = UIImageView()
        logoView.tintColor = .themedDetailedText
        logoView.contentMode = .scaleAspectFill
        logoView.addWidthConstraint(.imageWidth)
        self.logoView = logoView

        customContentView.directionalLayoutMargins = NSDirectionalEdgeInsets(horizontal: .defaultSpacing * 2, vertical: .verticalSpacing)

        let labelsStackView = UIStackView(arrangedSubviews: [primaryLabel, secondaryLabel])
        labelsStackView.axis = .vertical
        labelsStackView.spacing = .verticalSpacing

        let stackView = UIStackView(arrangedSubviews: [logoView, labelsStackView])
        stackView.alignment = .center
        stackView.spacing = .defaultSpacing * 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        customContentView.addSubview(stackView)
        stackView.fitToSuperview(obeyMargins: true)
    }
}

// MARK: - Constants

private extension CGFloat {
    static var imageWidth: CGFloat { return 50 }
    static var defaultSpacing: CGFloat { return 8 }
    static var verticalSpacing: CGFloat { return 4 }
}
#endif
