import Foundation

class GroupingService {
    private func get() throws -> [Rule] {
        guard let data = RawProvider.groupsJSON.data(using: .utf8) else {
            throw InternalError(description: "Unable to convert data to utf8")
        }
        
        let core = try JSONDecoder().decode(Core.self, from: data)
        return core.items
    }
    
    func group(networks: [PaymentNetwork]) -> [[PaymentNetwork]] {
        do {
            let rules = try get()
            let groupedNetworks = networks.grouped(using: rules)
            return groupedNetworks
        } catch {
            // Grouping service was unable to return rules, skip grouping
            return networks.map { [$0] }
        }
    }
    
   // MARK: - Model
    
    private struct Core: Decodable {
        let items: [Rule]
    }
    
    struct Rule: Decodable {
        let code: String
        let regex: NSRegularExpression
        
        enum CodingKeys: String, CodingKey {
            case code, regex
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            code = try container.decode(String.self, forKey: .code)
            
            let regexString = try container.decode(String.self, forKey: .regex)
            regex = try NSRegularExpression(pattern: regexString, options: [])
        }
    }
}

// MARK: - Grouping extension

private extension Sequence where Element == PaymentNetwork {
    func grouped(using rules: [GroupingService.Rule]) -> [[PaymentNetwork]] {
        var ungroupedNetworks = [PaymentNetwork]()
        var groupedNetworks = [PaymentNetwork]()
        
        for network in self {
            let isGroupingAllowed = (rules.first(withCode: network.applicableNetwork.code) != nil)
            if isGroupingAllowed {
                groupedNetworks.append(network)
            } else {
                ungroupedNetworks.append(network)
            }
        }
        
        var groupedResult = ungroupedNetworks.map { [$0] }
        groupedResult.append(groupedNetworks)
        
        return groupedResult
    }
}

private extension Sequence where Element == GroupingService.Rule {
    func first(withCode: String) -> Element? {
        for item in self where item.code == withCode {
            return item
        }
        
        return nil
    }
}
