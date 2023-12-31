//
//  MoneyScreenshots.swift
//  MoneyScreenshots
//
//  Created by Daniel Springer on 11/17/22.
//  Copyright © 2024 Daniel Springer. All rights reserved.
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

        XCTAssertTrue(app.staticTexts["Welcome"].firstMatch
            .waitForExistence(timeout: 5))
        takeScreenshot(named: "2-tutorial")

        app.staticTexts["Settings"].tap()

        XCTAssertTrue(app.staticTexts["Settings"].firstMatch.waitForExistence(timeout: 5))
        takeScreenshot(named: "3-settings")

        XCTAssertTrue(app.buttons["Done"].firstMatch.waitForExistence(timeout: 5))
        app.buttons["Done"].firstMatch.tap()

        XCTAssertTrue(app.staticTexts[Const.UIMsg.dailyMakeableRemaining].firstMatch
            .waitForExistence(timeout: 5))
        takeScreenshot(named: "1-home")

        app.buttons["Help"].firstMatch.tap()
        XCTAssertTrue(app.buttons[Const.UIMsg.contact].firstMatch.waitForExistence(timeout: 5))
        takeScreenshot(named: "4-help")
        app.tap()

    }


    func takeScreenshot(named name: String) {
        // Take the screenshot
        let fullScreenshot = XCUIScreen.main.screenshot()

        // Create a new attachment to save our screenshot
        // and give it a name consisting of the "named"
        // parameter and the device name, so we can find
        // it later.

        let theme = UITraitCollection.current.userInterfaceStyle == .dark ? "dark" : "light"

        let screenshotAttachment = XCTAttachment(
            uniformTypeIdentifier: "public.png",
            name: "Screenshot-\(UIDevice.current.name)-\(theme)-\(name).png",
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
