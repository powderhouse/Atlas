//
//  atlasUITests.swift
//  atlasUITests
//
//  Created by Alec Resnick on 11/15/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import XCTest

class AtlasUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInstallation() {
        let app = XCUIApplication()

        let accountModal = app.dialogs["Account Controller"]
        XCTAssert(accountModal.staticTexts["Welcome!"].exists)
        XCTAssert(accountModal.staticTexts["Please enter your email:"].exists)
        
        accountModal.textFields["Email"].typeText("test@example.com")
        accountModal.buttons["Save"].click()

        let window = XCUIApplication().windows["Window"]
        XCTAssert(window.staticTexts["Account: test@example.com"].exists)
    }
    
    func testInitialFolderIsCreated() {
        
    }
    
}
