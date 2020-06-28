import Foundation

extension Input.Field {
    /// Generic input field model that is used for all `localizableInputElements` that doesn't have explict type
    class Generic: BasicText, TextInputField {
        var maxInputLength: Int? { nil }
    }
}

#if canImport(UIKit)
import UIKit

extension Input.Field.Generic: CellRepresentable, DefinesKeyboardStyle {}
#endif
