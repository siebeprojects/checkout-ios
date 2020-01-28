import Foundation
@testable import Payment

extension MockFactory {
    class Validation {}
}


extension MockFactory.Validation {
    static var validationTestCases: [Network] {
        let jsonData = validationJSON.data(using: .utf8)!
        return try! JSONDecoder().decode([Network].self, from: jsonData)
    }
    
    static var validationJSON: String {
        return """
            [
              {
                "networkCode": "UNIONPAY",
                "inputElements": [
                  {
                    "name": "verificationCode",
                    "tests": [
                      {
                        "value": "123",
                        "error": null
                      },
                      {
                        "value": "12a",
                        "error": "INVALID_VERIFICATION_CODE"
                      }
                    ]
                  }
                ]
              }
            ]
        """
    }
}

extension MockFactory.Validation {
    struct Network: Decodable {
        let networkCode: String
        let inputElements: [InputElement]
    }

    struct InputElement: Decodable {
        let name: String?
        let type: String?
        let tests: [InputElementTestCase]
    }

    struct InputElementTestCase: Decodable {
        let value: String?
        let error: String?
    }
}
