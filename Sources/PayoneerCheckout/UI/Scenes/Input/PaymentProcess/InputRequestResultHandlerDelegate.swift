// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking
import UIKit

protocol InputRequestResultHandlerDelegate: AnyObject {
    func requestHandler(present viewControllerToPresent: UIViewController)
    func requestHandler(route result: Result<OperationResult, ErrorInfo>, forRequestType requestType: RequestSender.RequestType)
    func requestHandler(inputShouldBeChanged error: ErrorInfo)
    func requestHandler(communicationFailedWith error: ErrorInfo, forRequestType requestType: RequestSender.RequestType)
}
