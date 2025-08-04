//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Muhammed Nurmukhanov on 02.08.2025.
//

import XCTest
@testable import ImageFeed

final class ImageFeedUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews[AccessibilityIdentifiers.webView.rawValue]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.textFields.element(boundBy: 0)
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("")
        
        print(app.debugDescription)
        webView.tap()
        sleep(2)
        
        let passwordTextField = webView.secureTextFields.element(boundBy: 0)
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("")
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        sleep(2)
        
        cellToLike.buttons[AccessibilityIdentifiers.likeButtonOff.rawValue].tap()
        
        sleep(2)
        
        cellToLike.buttons[AccessibilityIdentifiers.likeButtonOn.rawValue].tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["buttonBackward"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts[""].exists)
        XCTAssertTrue(app.staticTexts[""].exists)
        
        app.buttons[AccessibilityIdentifiers.exitButton.rawValue].tap()
        
        app.alerts[AccessibilityIdentifiers.logoutAlert.rawValue].scrollViews.otherElements.buttons["Да"].tap()
    }
}
