import Foundation

extension String {
    func remove(charactersIn characterSet: CharacterSet) -> Self {
        return components(separatedBy: characterSet).joined(separator: "")
    }
}
