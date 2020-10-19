import XCTest

class UITests: XCTestCase {
    let paymentSessionService = PaymentSessionService()!

    var sessionURL: URL!

    override func setUpWithError() throws {
        continueAfterFailure = false

        let sessionExpectation = expectation(description: "Create payment session")
        let transaction = Transaction.loadFromTemplate()
        paymentSessionService.create(using: transaction, completion: { (result) in
            switch result {
            case .success(let url):
                self.sessionURL = url
            case .failure(let error):
                XCTFail(error)
                fatalError()
            }

            sessionExpectation.fulfill()
        })

        wait(for: [sessionExpectation], timeout: 5)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        print(sessionURL.absoluteString)
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}
