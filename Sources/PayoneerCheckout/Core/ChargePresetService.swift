// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Risk
import Networking
import UIKit
import Payment

protocol ChargePresetServiceProtocol {
    func chargePresetAccount(usingListResultURL listResultURL: URL, completion: @escaping (_ result: CheckoutResult) -> Void, presentationRequest: @escaping (_ viewControllerToPresent: UIViewController) -> Void)
}

final class ChargePresetService: ChargePresetServiceProtocol {
    private let paymentServiceFactory: PaymentServicesFactory

    private let connection: Connection = URLSessionConnection()
    private var riskService: RiskService

    init(paymentServices: [PaymentService.Type], riskService: RiskService) {
        self.paymentServiceFactory = PaymentServicesFactory(connection: connection, services: paymentServices)
        self.riskService = riskService
    }

    func chargePresetAccount(usingListResultURL listResultURL: URL, completion: @escaping (_ result: CheckoutResult) -> Void, presentationRequest: @escaping (_ viewControllerToPresent: UIViewController) -> Void) {
        getListResult(from: listResultURL) { [weak self] result in
            switch result {
            case .success(let listResult):
                do {
                    if let riskProviderParameters = listResult.riskProviders {
                        self?.riskService.loadRiskProviders(withParameters: riskProviderParameters)
                    }

                    try self?.chargePresetAccount(
                        from: listResult,
                        completion: { result in
                            DispatchQueue.main.async {
                                completion(result)
                            }
                        },
                        presentationRequest: { viewControllerToPresent in
                            DispatchQueue.main.async {
                                presentationRequest(viewControllerToPresent)
                            }
                        })
                } catch {
                    let errorInfo = CustomErrorInfo.createClientSideError(from: error)
                    let result = CheckoutResult(result: .failure(errorInfo))

                    DispatchQueue.main.async {
                        completion(result)
                    }
                }
            case .failure(let error):
                let errorInfo: ErrorInfo = {
                    if let errorInfo = error as? ErrorInfo { return errorInfo }
                    return CustomErrorInfo.createClientSideError(from: error)
                }()

                let result = CheckoutResult(result: .failure(errorInfo))

                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }

    private func getListResult(from url: URL, completion: @escaping ((Result<ListResult, Error>) -> Void)) {
        let getListResult = NetworkRequest.GetListResult(url: url)
        let getListResultOperation = SendRequestOperation(connection: connection, request: getListResult)
        getListResultOperation.downloadCompletionBlock = { result in
            switch result {
            case .success(let listResult):
                completion(.success(listResult))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        getListResultOperation.start()
    }

    private func chargePresetAccount(from listResult: ListResult, completion: @escaping (_ result: CheckoutResult) -> Void, presentationRequest: @escaping (_ viewControllerToPresent: UIViewController) -> Void) throws {
        guard let presetAccount = listResult.presetAccount else {
            let error = InternalError(description: "Payment session doesn't contain preset account")
            throw error
        }

        guard listResult.operationType == "PRESET" else {
            let error = InternalError(description: "List result doesn't contain operation type or operation type is not PRESET")
            throw error
        }

        let riskData = riskService.collectRiskData()

        // Find payment service
        guard let service = paymentServiceFactory.createPaymentService(forNetworkCode: presetAccount.code, paymentMethod: presetAccount.method, providers: presetAccount.providers)
        else {
            let error = InternalError(description: "Payment service for preset account wasn't found")
            let errorInfo = CustomErrorInfo.createClientSideError(from: error)
            let result = CheckoutResult(result: .failure(errorInfo))
            completion(result)
            return
        }

        // Prepare OperationRequest
        let networkInformation = NetworkInformation(networkCode: presetAccount.code, paymentMethod: presetAccount.method, operationType: presetAccount.operationType, links: presetAccount.links)
        let operationRequest = OperationRequest(networkInformation: networkInformation, form: nil, riskData: riskData)

        // Send request
        service.processPayment(
            operationRequest: operationRequest,
            completion: { result in
                switch result {
                case .success(let operationResult):
                    completion(CheckoutResult(result: .success(operationResult)))
                case .failure(let error):
                    if let errorInfo = error as? ErrorInfo {
                        completion(CheckoutResult(result: .failure(errorInfo)))
                    } else {
                        completion(CheckoutResult(result: .failure(CustomErrorInfo.createClientSideError(from: error))))
                    }
                }
            },
            presentationRequest: presentationRequest
        )
    }
}
