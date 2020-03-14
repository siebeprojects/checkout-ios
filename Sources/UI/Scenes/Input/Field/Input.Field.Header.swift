import UIKit
import Foundation

extension Input.Field {
    final class Header {
        let logoData: Data?
        let label: String
        var detailedLabel: String?

        private init(logoData: Data?, label: String) {
            self.logoData = logoData
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
            
            self.init(logoData: registeredAccount.logo?.value, label: label)
            
            if let expiryMonth = registeredAccount.apiModel.maskedAccount.expiryMonth, let expiryYear = registeredAccount.apiModel.maskedAccount.expiryYear {
                detailedLabel = String(format: "%02d", expiryMonth) + " / " + String(expiryYear).suffix(2)
            }
        }
    }
}

extension Input.Field.Header: CellRepresentable {
    func configure(cell: UITableViewCell) {
        switch cell {
        case let cell as Input.Table.LogoTextCell: cell.configure(with: self)
        case let cell as Input.Table.DetailedTextLogoCell: cell.configure(with: self)
        default:
            assertionFailure("Called configure(cell:) from unexpected UITableViewCell")
            return
        }
    }
    
    func dequeueCell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if detailedLabel != nil {
            return tableView.dequeueReusableCell(Input.Table.DetailedTextLogoCell.self, for: indexPath)
        } else {
            return tableView.dequeueReusableCell(Input.Table.LogoTextCell.self, for: indexPath)
        }
    }
}
