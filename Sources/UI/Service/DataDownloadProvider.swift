import UIKit

class DataDownloadProvider {
    let operationQueue = OperationQueue()
    let connection: Connection

    init(connection: Connection) {
        self.connection = connection
    }

    func downloadImages(for models: [ContainsLoadableImage], completion: @escaping () -> Void) {
        // Final operation that would call completion block
        let completionOperation = BlockOperation {
            completion()
        }

        // Add download operations
        for model in models {
            guard case let .notLoaded(url) = model.loadable else {
                continue
            }

            let downloadRequest = DownloadData(from: url)
            let sendRequestOperation = SendRequestOperation(connection: connection, request: downloadRequest)
            sendRequestOperation.downloadCompletionBlock = {
                model.loadable = self.makeResponse(for: $0)
            }
            completionOperation.addDependency(sendRequestOperation)
            operationQueue.addOperation(sendRequestOperation)
        }

        operationQueue.addOperation(completionOperation)
    }
    
    /// Convert download result to loadable image model
    private func makeResponse(for downloadResult: Result<Data, Error>) -> Loadable<UIImage>? {
        switch downloadResult {
        case .success(let data):
            if let image = UIImage(data: data) {
                return .loaded(.success(image))
            } else {
                let error = InternalError(description: "Unable to convert data to image")
                return .loaded(.failure(error))
            }
        case .failure(let error):
            return .loaded(.failure(error))
        }
    }
}

protocol ContainsLoadableImage: class {
    var loadable: Loadable<UIImage>? { get set }
}

extension PaymentNetwork: ContainsLoadableImage {
    var loadable: Loadable<UIImage>? {
        get { logo }
        set { logo = newValue }
    }
}

extension RegisteredAccount: ContainsLoadableImage {
    var loadable: Loadable<UIImage>? {
        get { logo }
        set { logo = newValue }
    }
}
