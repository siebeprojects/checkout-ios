import Foundation

protocol InputModifier {
    func modify(replaceableString: inout ReplaceableString)
}
