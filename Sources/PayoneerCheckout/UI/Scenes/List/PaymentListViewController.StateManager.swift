import UIKit

extension PaymentListViewController {
    class StateManager {
        weak var vc: PaymentListViewController!
        var viewManager: ViewManager { vc.viewManager }

        fileprivate var tableController: List.Table.Controller?

        var viewState: ViewState = .listLoading {
            didSet { changeState(to: viewState, from: oldValue) }
        }
    }
}

extension PaymentListViewController.StateManager {
    fileprivate func changeState(to newState: ViewState, from oldState: ViewState) {
        // Clean UI from old state
        switch oldState {
        case .listLoading:
            setActivityIndicatorState(isActive: false)
        case .failure:
            dismissAlertController()
        case .networksList:
            // Don't hide network list when switching to the new state
            break
        }

        // Perfom needed actions for the new UI state
        switch newState {
        case .listLoading:
            do {
                setActivityIndicatorState(isActive: true)
                try showPaymentMethods(for: nil)
            } catch {
                let errorInfo = CustomErrorInfo.createClientSideError(from: error)
                vc.dismiss(with: .failure(errorInfo))
            }
        case .failure(let error):
            vc.present(error: error)
        case .networksList(let session):
            do {
                try showPaymentMethods(for: session)
            } catch {
                let errorInfo = CustomErrorInfo.createClientSideError(from: error)
                vc.dismiss(with: .failure(errorInfo))
            }
        }
    }

    private func showPaymentMethods(for session: UIModel.PaymentSession?) throws {
        guard let session = session else {
            // Hide payment methods
            vc.methodsTableView?.removeFromSuperview()
            vc.methodsTableView = nil
            tableController = nil

            return
        }

        // Show payment methods
        let methodsTableView = viewManager.addMethodsTableView()

        let tableController = try List.Table.Controller(tableView: methodsTableView, session: session, translationProvider: vc.sharedTranslationProvider, modalPresenter: vc)
        tableController.delegate = vc
        self.tableController = tableController

        methodsTableView.dataSource = tableController.dataSource
        methodsTableView.delegate = tableController
        methodsTableView.prefetchDataSource = tableController

        methodsTableView.invalidateIntrinsicContentSize()
    }

    private func setActivityIndicatorState(isActive: Bool) {
        if isActive == false {
            // Hide activity indicator
            viewManager.removeActivityIndicator()
            return
        }

        if vc.activityIndicator != nil { return }

        viewManager.addActivityIndicator()
    }

    private func dismissAlertController() {
        vc.errorAlertController?.dismiss(animated: true)
    }
}

extension PaymentListViewController.StateManager {
    enum ViewState {
        case listLoading
        case failure(UIAlertController.AlertError)
        case networksList(UIModel.PaymentSession)
    }
}
