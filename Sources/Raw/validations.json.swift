import Foundation

extension RawProvider {
    static var validationsJSON: String {
        """
        [
            {
                "code": "AMEX",
                "items": [
                    {
                        "type": "number",
                        "regex": "^3[47][0-9]{13}$",
                        "maxLength": 19
                    },
                    {
                        "type": "verificationCode",
                        "regex": "^[0-9]{4}$",
                        "maxLength": 4
                    }
                ]
            },
            {
                "code": "CASTORAMA",
                "items": [
                    {
                        "type": "number",
                        "regex": "[1-9]{1}[0-9]{15,18}$",
                        "maxLength": 19
                    },
                    {
                        "type": "verificationCode",
                        "regex": "^[0-9]{4}$",
                        "maxLength": 4
                    }
                ]
            },
            {
                "code": "DINERS",
                "items": [
                    {
                        "type": "number",
                        "regex": "^3(?:0[0-5]|[689][0-9])[0-9]{11}$",
                        "maxLength": 19
                    },
                    {
                        "type": "verificationCode",
                        "regex": "^[0-9]{3}$",
                        "maxLength": 3
                    }
                ]
            },
            {
                "code": "DISCOVER",
                "items": [
                    {
                        "type": "number",
                        "regex": "^(?:6011|622[1-9]|64[4-9][0-9]|65[0-9]{2})[0-9]{12}$",
                        "maxLength": 19
                    },
                    {
                        "type": "verificationCode",
                        "regex": "^[0-9]{3}$",
                        "maxLength": 3
                    }
                ]
            },
            {
                "code": "MASTERCARD",
                "items": [
                    {
                        "type": "number",
                        "regex": "^5[1-5][0-9]{14}|(222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)[0-9]{12}$",
                        "maxLength": 19
                    },
                    {
                        "type": "verificationCode",
                        "regex": "^[0-9]{3}$",
                        "maxLength": 3
                    }
                ]
            },
            {
                "code": "UNIONPAY",
                "items": [
                    {
                        "type": "number",
                        "regex": "^62[0-5][0-9]{13,16}$",
                "maxLength": 19
                    },
                    {
                        "type": "verificationCode",
                        "regex": "^[0-9]{3}$",
                        "maxLength": 3
                    }
                ]
            },
            {
                "code": "VISA",
                "items": [
                    {
                        "type": "number",
                        "regex": "^4(?:[0-9]{12}|[0-9]{15}|[0-9]{18})$",
                "maxLength": 19
                    },
                    {
                        "type": "verificationCode",
                        "regex": "^[0-9]{3}$",
                        "maxLength": 3
                    }
                ]
            },
            {
                "code": "VISA_DANKORT",
                "items": [
                    {
                        "type": "number",
                        "regex": "^4(?:[0-9]{12}|[0-9]{15})$",
                        "maxLength": 19
                    },
                    {
                        "type": "verificationCode",
                        "regex": "^[0-9]{3}$",
                        "maxLength": 3
                    }
                ]
            },
            {
                "code": "VISAELECTRON",
                "items": [
                    {
                        "type": "number",
                        "regex": "^4[0-9]{15}$",
                "maxLength": 19
                    },
                    {
                        "type": "verificationCode",
                        "regex": "^[0-9]{3}$",
                        "maxLength": 3
                    }
                ]
            },
            {
                "code": "CARTEBANCAIRE",
                "items": [
                    {
                        "type": "number",
                        "regex": "^(2|[4-6])[0-9]{10,16}",
                "maxLength": 19
                    },
                    {
                        "type": "verificationCode",
                        "regex": "^[0-9]*$"
                    }
                ]
            },
            {
                "code": "MAESTRO",
                "items": [
                    {
                        "type": "number",
                        "regex": "^(50|59|6[0-9])[0-9]{10,17}",
                "maxLength": 19
                    },
                    {
                        "type": "verificationCode",
                        "regex": "^[0-9]*$"
                    }
                ]
            },
            {
                "code": "MAESTROUK",
                "items": [
                    {
                        "type": "number",
                        "regex": "^(50|59|6[0-9])[0-9]{10,17}",
                "maxLength": 19
                    },
                    {
                        "type": "verificationCode",
                        "regex": "^[0-9]*$"
                    }
                ]
            }

        ]
        """
    }
}


//{
//    "code": "SEPADD",
//    "items": [
//        {
//            "type": "bic",
//            "hide": true
//        }
//    ]
//}
