import Foundation

class UppercaseInputModifier: InputModifier {
    func modify(replaceableString: inout ReplaceableString) {
        replaceableString.replacementText = replaceableString.replacementText.uppercased()
    }
}
