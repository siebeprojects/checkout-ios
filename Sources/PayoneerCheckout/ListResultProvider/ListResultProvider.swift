// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking

class ListResultProvider {
    private let paymentServicesFactory: PaymentServicesFactory
    private let connection: Connection

    /// Could contain list result after running `fetchListResult(from:completion:)`.
    /// - Note: could contain list result even if `fetchListResult(from:completion:)` produced an error but list result was downloaded successfully.
    private(set) var listResult: ListResult?

    init(connection: Connection, paymentServicesFactory: PaymentServicesFactory) {
        self.connection = connection
        self.paymentServicesFactory = paymentServicesFactory
    }

    func fetchListResult(from paymentSessionURL: URL, completion: @escaping ((Result<ListResultNetworks, Error>) -> Void)) {
        let job = getListResult ->> checkIntegrationType ->> checkOperationType ->> checkInteractionCode ->> filterUnsupportedNetworks ->> requireNotEmpty

        job(paymentSessionURL) { completion($0) }
    }

    private func getListResult(from url: URL, completion: @escaping ((Result<ListResult, Error>) -> Void)) {
        let getListResult = NetworkRequest.GetListResult(url: url)
        let getListResultOperation = SendRequestOperation(connection: connection, request: getListResult)
        getListResultOperation.downloadCompletionBlock = { result in
            switch result {
            case .success(let listResult):
                self.listResult = listResult
                completion(.success(listResult))
            case .failure(let error): completion(.failure(error))
            }
        }
        getListResultOperation.start()
    }

    private func checkIntegrationType(for listResult: ListResult, completion: ((Result<ListResult, Error>) -> Void)) {
        guard listResult.integrationType == "MOBILE_NATIVE" else {
            let interaction = Interaction(code: .ABORT, reason: .CLIENTSIDE_ERROR)
            let resultInfo = "Integration type is not supported: " + listResult.integrationType
            let paymentError = CustomErrorInfo(resultInfo: resultInfo, interaction: interaction, underlyingError: nil)
            completion(.failure(paymentError))
            return
        }

        completion(.success(listResult))
    }

    private func checkOperationType(for listResult: ListResult, completion: @escaping ((Result<ListResult, Error>) -> Void)) {
        guard listResult.operationType != nil else {
            let error = InternalError(description: "Operation type is not specified")
            completion(.failure(error))
            return
        }

        completion(.success(listResult))
    }

    private func checkInteractionCode(listResult: ListResult, completion: ((Result<ListResult, Error>) -> Void)) {
        guard Interaction.Code(rawValue: listResult.interaction.code) == .some(.PROCEED) else {
            // If result is not PROCEED, route interaction and resultInfo to a merchant
            let errorInfo = CustomErrorInfo(resultInfo: listResult.resultInfo, interaction: listResult.interaction, underlyingError: nil)
            completion(.failure(errorInfo))
            return
        }

        // Interaction code is PROCEED, route result
        completion(.success(listResult))
    }

    private func filterUnsupportedNetworks(listResult: ListResult, completion: ((ListResultNetworks) -> Void)) {
        // Filter networks
        var filteredPaymentNetworks = listResult.networks.applicable.filter { network in
            paymentServicesFactory.isSupported(networkCode: network.code, paymentMethod: network.method)
        }

        // Filter networks with `NONE/NONE` registration options in `UPDATE` flow, more info at: [PCX-1396](https://optile.atlassian.net/browse/PCX-1396) AC #1.a
        if listResult.operationType == "UPDATE" {
            filteredPaymentNetworks = filteredPaymentNetworks.filter { network in
                if case .NONE = network.registration, case .NONE = network.recurrence {
                    return false
                } else {
                    return true
                }
            }
        }

        // Filter accounts
        let filteredRegisteredNetworks: [AccountRegistration]
        if let accounts = listResult.accounts {
            filteredRegisteredNetworks = accounts.filter {
                paymentServicesFactory.isSupported(networkCode: $0.code, paymentMethod: $0.method)
            }
        } else {
            filteredRegisteredNetworks = .init()
        }

        // Filter preset account
        let filteredPresetAccount: PresetAccount? = {
            guard let presetAccount = listResult.presetAccount else { return nil }
            guard paymentServicesFactory.isSupported(networkCode: presetAccount.code, paymentMethod: presetAccount.method) else { return nil }
            return presetAccount
        }()

        let filteredNetworks = ListResultNetworks.FilteredNetworks(
            applicableNetworks: filteredPaymentNetworks,
            accountRegistrations: filteredRegisteredNetworks,
            presetAccount: filteredPresetAccount)
        let networks = ListResultNetworks(listResult: listResult, filteredNetworks: filteredNetworks)

        completion(networks)
    }

    private func requireNotEmpty(_ listResultNetworks: ListResultNetworks, completion: ((Result<ListResultNetworks, Error>) -> Void)) {
        if
            listResultNetworks.filteredNetworks.applicableNetworks.isEmpty &&
            listResultNetworks.filteredNetworks.accountRegistrations.isEmpty &&
            listResultNetworks.filteredNetworks.presetAccount == nil
        {
            let error = InternalError(description: "List result after filtering doesn't contain any networks. Please check that you loaded needed payment services.")
            completion(.failure(error))
        } else {
            completion(.success(listResultNetworks))
        }
    }
}
