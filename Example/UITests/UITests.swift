import XCTest

class UITests: XCTestCase {
    let paymentSessionService = PaymentSessionService()!

    var sessionURL: URL!

    override func setUpWithError() throws {
        continueAfterFailure = false

        // Create payment session
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

    func testVISAProceed() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Initial screen
        let tablesQuery = app.tables
        if tablesQuery.buttons["Clear text"].exists {
            tablesQuery.buttons["Clear text"].tap()
        }
        tablesQuery.textFields.firstMatch.typeText(sessionURL.absoluteString)
        tablesQuery.staticTexts["Send request"].tap()

        // List
        app.tables.staticTexts["Cards"].tap()

        // Input
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["Card Number"].tap()
        collectionViewsQuery.textFields["Card Number"].typeText("4111111111111111")

        collectionViewsQuery.textFields["MM / YY"].tap()
        collectionViewsQuery.textFields["MM / YY"].typeText("1030")

        collectionViewsQuery.textFields["Security Code"].tap()
        collectionViewsQuery.textFields["Security Code"].typeText("111")

        collectionViewsQuery.textFields["Name on card"].tap()
        collectionViewsQuery.textFields["Name on card"].typeText("Test Test")

        collectionViewsQuery.buttons["Pay"].tap()

        // Check result
        let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
        let expectedResult = "ResultInfo: Approved Interaction code: PROCEED Interaction reason: OK Error: n/a"
        XCTAssertEqual(expectedResult, interactionResult)
    }
}
