//
//  BabbelGameUITests.swift
//  BabbelGameUITests
//
//  Created by Hakan Yildizay on 25.06.2022.
//

import XCTest

class BabbelGameUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testIfApplicationQuitsWhenOnlyCorrectButtonIsPressed() throws {

        let app = XCUIApplication()
        app.launchArguments = ["UITest"]
        app.launch()

        let correctButton = app.buttons.element(matching: .button, identifier: "btnCorrect")
        let wrongButton = app.buttons.element(matching: .button, identifier: "btnWrong")
        addUIInterruptionMonitor(withDescription: "alerthandler") { (alert) -> Bool in

            let alertButton = alert.buttons["Close"]
            if alertButton.exists {
                alertButton.tap()
                return true
            }

            return false
        }
        app.tap()

        var alertView = app.alerts["Game Ended"]
        while !alertView.exists {

            let predicate = NSPredicate(format: "isHittable == 1")

            expectation(for: predicate, evaluatedWith: wrongButton, handler: nil)
            waitForExpectations(timeout: 5, handler: nil)

            expectation(for: predicate, evaluatedWith: correctButton, handler: nil)
            waitForExpectations(timeout: 5, handler: nil)

            let random = arc4random_uniform(100)
            if random % 2 == 0 {
                if correctButton.exists {
                    correctButton.tap()
                }
            } else {
                if wrongButton.exists {
                    wrongButton.tap()
                }

            }

            alertView = app.alerts["Game Ended"]

        }

    }

}
