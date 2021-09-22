// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

extension Input.ViewController {
    struct PaymentModelFabric {}
}

extension Input.ViewController.PaymentModelFabric {
    func createInputFields(from network: Input.Network) throws -> [String: String] {
        // TODO: Rework when send POST request with extra elements
        var inputFields = [InputField]()

        if let inputElements = network.uiModel.inputSections[.inputElements] {
            inputFields += inputElements.inputFields
        }

        if let registration = network.uiModel.inputSections[.registration] {
            inputFields += registration.inputFields
        }

        return try createInputElementsDictionary(from: inputFields)
    }
}

extension Input.ViewController.PaymentModelFabric {
    fileprivate func createInputElementsDictionary(from inputFields: [InputField]) throws -> [String: String] {
        var dictionary = [String: String]()
        for inputField in inputFields {
            switch inputField.id {
            case .expiryDate:
                let date = ExpirationDate(shortDate: inputField.value)
                dictionary["expiryMonth"] = date.getMonth()
                dictionary["expiryYear"] = try date.getYear()
            case .combinedRegistration:
                // FIXME: don't do nothing, is not supported yet
                break
            case .inputElementName(let name):
                dictionary[name] = inputField.value
            }
        }

        return dictionary
    }
}

private struct ExpirationDate {
    /// Date in `MMYY` format
    let shortDate: String

    func getMonth() -> String {
        return String(shortDate.prefix(2))
    }

    func getYear() throws -> String {
        let shortYear = String(shortDate.suffix(2))
        return try DateFormatter.string(fromShortYear: shortYear)
    }
}
