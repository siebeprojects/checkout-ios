import Foundation

extension Bool {
    var stringValue: String {
        return self ? "true" : "false"
    }
}

extension Bool {
    init?(stringValue: String) {
        switch stringValue {
        case "true": self = true
        case "false": self = false
        default: return nil
        }
    }
}
