import UIKit

extension Input.Table {
    class Validator {
        let dataSource: DataSource
        weak var collectionView: UICollectionView!

        init(dataSource: DataSource) {
            self.dataSource = dataSource
        }
    }
}

extension Input.Table.Validator {
    func removeValidationError(for cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }

        let cellRepresentable = dataSource.model[indexPath.section][indexPath.row]

        if let validatableModel = cellRepresentable as? Validatable, validatableModel.validationErrorText != nil {
            validatableModel.validationErrorText = nil

            // Update cell's view if cell is on the screen
            if let textFieldViewCell = collectionView.cellForItem(at: indexPath) as? Input.Table.TextFieldViewCell {
                textFieldViewCell.showValidationResult(for: validatableModel)
                textFieldViewCell.layoutIfNeeded()
            }
        }
    }

    /// Validate all models and display validation results in cells
    /// - Returns: is all fields are valid
    @discardableResult func validateAll(option: Input.Field.Validation.Option) -> Bool {
        // We need to resign a responder to avoid double validation after `textFieldDidEndEditing` event (keyboard will disappear on table reload).
        collectionView.endEditing(true)

        var isValid = true

        for section in dataSource.model {
            for row in section {
                guard let validatable = row as? Validatable else { continue }
                validatable.validateAndSaveResult(option: option)

                if validatable.validationErrorText != nil {
                    isValid = false
                }
            }
        }

        collectionView.reloadData()

        return isValid
    }

    func validate(cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }

        let cellRepresentable = dataSource.model[indexPath.section][indexPath.row]
        guard let validatableRow = cellRepresentable as? Validatable else { return }

        let previousValidationErrorText = validatableRow.validationErrorText

        // Validate an input and update a model
        validatableRow.validateAndSaveResult(option: .preCheck)

        // Display validation result if cell is visible
        if previousValidationErrorText != validatableRow.validationErrorText, let cell = collectionView.cellForItem(at: indexPath) {
            do {
                try cellRepresentable.configure(cell: cell)
                cell.layoutIfNeeded()
            } catch {
                log(error)
            }
        }
    }
}
