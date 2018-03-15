//
//  Helper.swift
//  AtlasAppUITests
//
//  Created by Jared Cosulich on 3/14/18.
//

import Cocoa
import XCTest

class AtlasUITestCase: XCTestCase {

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
        
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func waitForElementToAppear(_ element: XCUIElement) -> Bool {
        let predicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate,
                                                    object: element)
        
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        return result == .completed
    }
    
    func login(_ app: XCUIApplication) {
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
    }
    
    //    //func assertTerminalContains(_ text: String) {
    //    //    let terminal = app.textViews["terminal"]
    //    //    let terminalText = terminal.value as? String ?? ""
    //    //    XCTAssertNotNil(terminalText.range(of: text), "The terminal does not contain the text: \(text)")
    //    //}
    //
    //    //func assertTerminalDoesNotContain(_ text: String) {
    //    //    let terminal = app.textViews["terminal"]
    //    //    let terminalText = terminal.value as? String ?? ""
    //    //    XCTAssertNil(terminalText.range(of: text), "The terminal contains the text: \(text)")
    //    //}
    
    func waitForTerminalToContain(_ text: String) {
        let terminalView = app.textViews["TerminalView"]
        
        let contains = NSPredicate(format: "value contains[c] %@", text)
        
        let subsitutedContains = contains.withSubstitutionVariables(["text": text])
        
        expectation(for: subsitutedContains, evaluatedWith: terminalView, handler: nil)
        waitForExpectations(timeout: 30, handler: nil)
    }
    
}

