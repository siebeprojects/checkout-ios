import Foundation

/// Used only by `Input.ViewController` to react on input value changes
protocol InputValueChangesListener: class {
    func valueDidChange(for field: InputField)
}
