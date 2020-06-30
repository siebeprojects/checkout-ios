import Foundation

protocol SnakeCaseRepresentable: RawRepresentable where Self: CaseIterable, Self.RawValue == String {}

extension SnakeCaseRepresentable {
    init?(rawValue: String) {
        for i in Self.allCases where i.rawValue == rawValue {
            self = i
            return
        }
        
        return nil
    }
    
    var rawValue: String {
        let name = String(describing: self)
        return name.camelCaseToSnakeCase().uppercased()
    }
}

fileprivate extension String {
    func camelCaseToSnakeCase() -> String {
        let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
        let normalPattern = "([a-z0-9])([A-Z])"
        return self.processCamalCaseRegex(pattern: acronymPattern)?
            .processCamalCaseRegex(pattern: normalPattern)?.lowercased() ?? self.lowercased()
    }
    
    private func processCamalCaseRegex(pattern: String) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
    }
}
