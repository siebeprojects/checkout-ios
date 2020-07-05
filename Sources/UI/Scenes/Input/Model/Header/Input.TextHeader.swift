import UIKit
import Foundation

extension Input {
    final class TextHeader {
        let logo: UIImage?
        let label: String
        var detailedLabel: String?

        private init(logo: UIImage?, label: String) {
            self.logo = logo
            self.label = label
        }

        /// Initializes header with transformed label and detailed label from `maskedAccount` data.
        convenience init(from registeredAccount: RegisteredAccount) {
            let label: String

            // Use custom transformation
            if let number = registeredAccount.apiModel.maskedAccount.number {
                // Expected input number format: `41 *** 1111`
                let maskedNumber = "•••• " + number.suffix(4)
                label = [registeredAccount.networkLabel, maskedNumber].joined(separator: " ")
                // Output: VISA •••• 1234
            } else if let iban = registeredAccount.apiModel.maskedAccount.iban {
                label = iban.prefix(2) + " •••• " + iban.suffix(2)
                // Output: DE •••• 24
            } else {
                // Fallback to server's display label
                label = registeredAccount.apiModel.maskedAccount.displayLabel ?? ""
            }

            self.init(logo: registeredAccount.logo?.value, label: label)

            if let expiryMonth = registeredAccount.apiModel.maskedAccount.expiryMonth, let expiryYear = registeredAccount.apiModel.maskedAccount.expiryYear {
                detailedLabel = String(format: "%02d", expiryMonth) + " / " + String(expiryYear).suffix(2)
            }
        }
    }
}

extension Input.TextHeader: CellRepresentable {
    func configure(cell: UICollectionViewCell) {
        switch cell {
        case let view as Input.Table.LogoTextView: view.configure(with: self)
        case let view as Input.Table.DetailedTextLogoView: view.configure(with: self)
        default: return
        }
    }
    
    func dequeueCell(for view: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        if detailedLabel == nil {
            return view.dequeueReusableCell(Input.Table.LogoTextView.self, for: indexPath)
        } else {
            return view.dequeueReusableCell(Input.Table.DetailedTextLogoView.self, for: indexPath)
        }
    }
}
