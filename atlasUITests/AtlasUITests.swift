//
//  atlasUITests.swift
//  atlasUITests
//
//  Created by Alec Resnick on 11/15/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import XCTest

class AtlasUITests: XCTestCase {
    
    var app: XCUIApplication!
        
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        app = XCUIApplication()
        
        app.launchEnvironment["atlasDirectory"] = NSTemporaryDirectory()
        app.launchEnvironment["TESTING"] = "true"

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        let accountModal = app.dialogs["Account Controller"]
        XCTAssert(accountModal.staticTexts["Welcome!"].exists)
        XCTAssert(accountModal.staticTexts["Please enter your GitHub credentials:"].exists)

        let usernameField = accountModal.textFields["GitHub Username"]
        usernameField.click()
        usernameField.typeText("atlastest")

        let passwordSecureTextField = accountModal.secureTextFields["GitHub Password"]
        passwordSecureTextField.click()
        passwordSecureTextField.typeText("1a2b3c4d")
        
        accountModal.buttons["Save"].click()
        
        let label = app.staticTexts["Account: atlastest"]
        let exists = NSPredicate(format: "exists == 1")
        
        expectation(for: exists, evaluatedWith: label, handler: nil)
        waitForExpectations(timeout: 30, handler: nil)
        
        XCTAssert(waitForElementToAppear(app.staticTexts["Current Project: General"]))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInstallation() {
        let window = app.windows["Window"]
        XCTAssert(window.buttons["+"].exists)
        
        XCTAssert(window.staticTexts["Current Project: General"].exists)
        XCTAssert(window.collectionViews.staticTexts["General"].exists)
                
        XCTAssert(window.staticTexts["GitHub Repository: https://github.com/atlastest/Atlas"].exists)
    }
    
    func testPersistence() {
        app.terminate()
        app.launchEnvironment["TESTING"] = nil
        app.launch()
        
        let window = app.windows["Window"]
        XCTAssert(window.staticTexts["Account: atlastest"].exists)
        XCTAssert(window.staticTexts["Current Project: General"].exists)
        XCTAssert(window.collectionViews.staticTexts["General"].exists)
        XCTAssert(window.staticTexts["GitHub Repository: https://github.com/atlastest/Atlas"].exists)
    }
    
    func testNewProject() {
        let window = app.windows["Window"]
        XCTAssertFalse(window.staticTexts["New Project"].exists)
        
        window.buttons["+"].click()
        XCTAssert(window.staticTexts["New Project"].exists)
        
        window.textFields["Project Name"].typeText("First Project")
        window.buttons["Save"].click()

        XCTAssert(waitForElementToAppear(app.staticTexts["Current Project: First Project"]))

        XCTAssertFalse(window.staticTexts["New Project"].exists)
    }
    
    func testProjectPersistence() {
        let window = app.windows["Window"]
        window.buttons["+"].click()
        window.textFields["Project Name"].typeText("First Project")
        window.buttons["Save"].click()

        XCTAssert(waitForElementToAppear(app.staticTexts["Current Project: First Project"]))

        app.terminate()
        app.launchEnvironment["TESTING"] = nil
        app.launch()
        
        XCTAssert(window.collectionViews.staticTexts["First Project"].exists)
    }
    
    func testSelectingProjects() {
        let window = app.windows["Window"]
        window.buttons["+"].click()
        window.textFields["Project Name"].typeText("First Project")
        window.buttons["Save"].click()
        
        XCTAssert(waitForElementToAppear(app.staticTexts["Current Project: First Project"]))

        window.buttons["+"].click()
        window.textFields["Project Name"].typeText("Second Project")
        window.buttons["Save"].click()
        
        XCTAssert(waitForElementToAppear(app.staticTexts["Current Project: Second Project"]))

        XCTAssert(window.collectionViews.staticTexts["First Project"].exists)
        window.collectionViews.staticTexts["First Project"].click()
        XCTAssert(window.staticTexts["Current Project: First Project"].exists)
    }
    
    func waitForElementToAppear(_ element: XCUIElement) -> Bool {
        let predicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate,
                                                    object: element)
        
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        return result == .completed
    }
}
