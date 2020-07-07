import UIKit

extension Input.Field {
    /// Label with no user interaction and pre-set value.
    class Label {
        let label: String
        let name: String
        var value: String

        var isEnabled: Bool = true

        init(label: String, name: String, value: String) {
            self.label = label
            self.name = name
            self.value = value
        }
    }
}

extension Input.Field.Label: InputField, CellRepresentable {}
