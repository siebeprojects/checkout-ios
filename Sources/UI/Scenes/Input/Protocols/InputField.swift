import Foundation

/// Generic UI model for input element
protocol InputField: class {
    var name: String { get }
    var value: String { get set }
}

extension InputField where Self: InputElementModel {
    var name: String { inputElement.name }
}
