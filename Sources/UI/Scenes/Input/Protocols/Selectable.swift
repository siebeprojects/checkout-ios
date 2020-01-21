import Foundation

protocol Selectable {
    var isSelected: Bool { get }
}

extension Sequence where Element: Selectable {
    /// Returns first selected item (`isSelected = true`)
    func firstSelection() -> Element? {
        for element in self where element.isSelected {
            return element
        }
        
        return nil
    }
}
