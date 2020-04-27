import Foundation

protocol InputModifier {
    func modify(text: ReplaceableString) -> ReplaceableString
}
