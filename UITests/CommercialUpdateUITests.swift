import XCTest

final class CommercialUpdateUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--screenshot", "--screenshot-tab", "2"]
        app.launch()
    }

    func testGalleryAndAllInteractiveTools() throws {
        let galleryCount = app.staticTexts["gallery-result-count"]
        XCTAssertTrue(galleryCount.waitForExistence(timeout: 30))
        XCTAssertFalse(galleryCount.label.hasPrefix("0 "))
        let gallerySearch = app.textFields["gallery-search-field"]
        XCTAssertTrue(gallerySearch.exists)
        let firstCard = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'gallery-card-'")).firstMatch
        XCTAssertTrue(firstCard.waitForExistence(timeout: 10)); firstCard.tap()

        app.terminate()
        app.launchArguments = ["--screenshot", "--screenshot-tab", "4"]
        app.launch()
        let toolsCount = app.staticTexts["tools-result-count"]
        XCTAssertTrue(toolsCount.waitForExistence(timeout: 15))
        XCTAssertEqual(toolsCount.label, "100 項")
        let toolsSearch = app.textFields["tools-search-field"]
        XCTAssertTrue(toolsSearch.exists)
        app.buttons["tool-1"].tap()
        let firstCheck = app.buttons["tool-check-0"]
        XCTAssertTrue(firstCheck.waitForExistence(timeout: 10)); firstCheck.tap()
        XCTAssertTrue(app.staticTexts["tool-risk-result"].exists)
    }
}
