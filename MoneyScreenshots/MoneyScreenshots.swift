//
//  MoneyScreenshots.swift
//  MoneyScreenshots
//
//  Created by dani on 11/17/22.
//

import XCTest

final class MoneyScreenshots: XCTestCase {

    var app: XCUIApplication!


    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()

        // We send a command line argument to our app,
        // to enable it to reset its state
        app.launchArguments.append("--moneyScreenshots")
    }


    func testExample() throws {
        // UI tests must launch the application that they test.
        app.launch()

        XCTAssertTrue(app.staticTexts["Daily Makeable Remaining:"].firstMatch.waitForExistence(timeout: 5))
        takeScreenshot(named: "home-workday")
        app.buttons["Settings"].firstMatch.tap()
        XCTAssertTrue(app.buttons["Done"].firstMatch.waitForExistence(timeout: 5))
        takeScreenshot(named: "home-workday")

    }


    func takeScreenshot(named name: String) {
        // Take the screenshot
        let fullScreenshot = XCUIScreen.main.screenshot()

        // Create a new attachment to save our screenshot
        // and give it a name consisting of the "named"
        // parameter and the device name, so we can find
        // it later.
        let screenshotAttachment = XCTAttachment(
            uniformTypeIdentifier: "public.png",
            name: "Screenshot-\(UIDevice.current.name)-\(name).png",
            payload: fullScreenshot.pngRepresentation,
            userInfo: nil)

        // Usually Xcode will delete attachments after
        // the test has run; we don't want that!
        screenshotAttachment.lifetime = .keepAlways

        // Add the attachment to the test log,
        // so we can retrieve it later
        add(screenshotAttachment)
    }

}
