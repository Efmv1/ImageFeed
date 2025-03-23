import XCTest
@testable import ImageFeed

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("e-mail")
        let toolbar = app.descendants(matching: .toolbar).element
        toolbar.buttons["Done"].tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("password")
        toolbar.buttons["Done"].tap()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        XCTAssertTrue(app.waitForExistence(timeout: 5))
        
        let tablesQuery = app.tables
        
        app.swipeUp()
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 2)
        
        cellToLike.buttons["nonActive"].tap()
        cellToLike.buttons["active"].tap()
        
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5))
        
        cellToLike.tap()
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        
        image.pinch(withScale: 0.5, velocity: -1)
        
        let backButton = app.buttons["nav back button white"]
        backButton.tap()
    }
    
    func testProfile() throws {
        XCTAssertTrue(app.waitForExistence(timeout: 5))
        
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.waitForExistence(timeout: 5))
        
        XCTAssertTrue(app.staticTexts["Name Lastname"].exists)
        
        app.buttons["exitButton"].tap()
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        
        XCTAssertTrue(app.waitForExistence(timeout: 5))
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
    }
}
