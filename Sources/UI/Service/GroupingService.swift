import Foundation

class GroupingService {
    private func get() throws -> [Rule] {
        guard let data = groupsJson.data(using: .utf8) else {
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

// MARK: - Raw JSON

private var groupsJson: String {
"""
{
    "items": [
        {
            "code": "DISCOVER",
            "regex": "^(6[045]|62212[6-9]|6221[3-9][0-9]|622[2-8][0-9]{2}|6229[01][0-9]|62292[0-5])[0-9]*$"
        },
        {
            "code": "MASTERCARD",
            "regex": "^(5[0-5]|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)[0-9]*$"
        },
        {
            "code": "DINERS",
            "regex": "^(2014|2149|30[059]|3[689])[0-9]*$"
        },
        {
            "code": "UNIONPAY",
            "regex": "^62[0-9]*$"
        },
        {
            "code": "AMEX",
            "regex": "^3[47][0-9]*$"
        },
        {
            "code": "JCB",
            "regex": "^35[0-9]*$"
        },
        {
            "code": "VISA",
            "regex": "^4[0-9]*$"
        }
    ]
}
"""
}
