// Based on https://github.com/luximetr/AnyFormatKit (MIT License)
// Based on commit: fe937c1e83574ad66f87f4a3eedc592440304077

import Foundation

/// Interface for formatter of TextInput, that allow change format of text during input
protocol TextInputFormatter: TextFormatter {
    func formatInput(currentText: String, range: NSRange, replacementString text: String) -> FormattedTextValue
}
