import Foundation

protocol Selectable {
    var isSelected: Bool { get }
}

extension Sequence where Element: Selectable {
    func firstSelection() -> Element? {
        for element in self where element.isSelected {
            return element
        }
        
        return nil
    }
}
