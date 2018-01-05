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
        
        assertTerminalContains("GitHub: https://github.com/atlastest/Atlas")
    }
    
    func testPersistence() {
        app.terminate()
        app.launchEnvironment["TESTING"] = nil
        app.launch()
        
        let window = app.windows["Window"]
        XCTAssert(window.staticTexts["Account: atlastest"].exists)
        XCTAssert(window.staticTexts["Current Project: General"].exists)
        XCTAssert(window.collectionViews.staticTexts["General"].exists)
        
        waitForTerminalToContain("GitHub: https://github.com/atlastest/Atlas")
    }
    
    func testNewProject() {
        let window = app.windows["Window"]
        XCTAssertFalse(window.staticTexts["New Project"].exists)
        
        window.buttons["+"].click()
        XCTAssert(window.staticTexts["New Project"].exists)
        
        window.textFields["Project Name"].typeText("First Project")
        window.buttons["Save"].click()

        waitForTerminalToContain("Create Project: First Project")
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

    func testCommitting() {
        let window = app.windows["Window"]
        XCTAssertFalse(window.buttons["Commit"].isEnabled)
        
        let commitArea = app.textViews["commit"]
        commitArea.click()
        commitArea.typeText("A commit message")
        
        XCTAssert(window.buttons["Commit"].isEnabled)
    }
    
    func testStagingAndUnstagingFile() {
        let terminal = app.textViews["terminal"]
        XCTAssertFalse(app.staticTexts["index.html"].exists)

        terminal.click()
        terminal.typeText("touch ../index.html\n")

        terminal.typeText("stage ../index.html\n")
        assertTerminalContains("“index.html” staged in “General”")
        XCTAssert(app.staticTexts["index.html"].exists)
        
        app/*@START_MENU_TOKEN@*/.collectionViews.groups["StagedFileViewItem"].buttons["-"]/*[[".scrollViews.collectionViews",".groups[\"StagedFileViewItem\"].buttons[\"-\"]",".buttons[\"-\"]",".collectionViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,1]]@END_MENU_TOKEN@*/.click()
        
        waitForTerminalToContain("“index.html” removed from staging in “General”")
        XCTAssertFalse(app.staticTexts["index.html"].exists)
    }
    
    func testCommitingFiles() {
        let window = app.windows["Window"]

        let terminal = window.textViews["terminal"]

        waitForTerminalToContain("Active Project: General")
        
        terminal.click()
        terminal.typeText("touch ../index.html\n")
        terminal.typeText("stage ../index.html\n")
        XCTAssert(waitForElementToAppear(window.staticTexts["index.html"]))
        
        let commitArea = window.textViews["commit"]
        commitArea.click()
        commitArea.typeText("The reason why I am adding these files.")
        window.buttons["Commit"].click()

        waitForTerminalToContain("1 file committed to “General”")

        let commitAreaValue = commitArea.value as? String
        XCTAssertEqual(commitAreaValue, "")

        XCTAssertFalse(window.staticTexts["index.html"].exists)
    }
    
    func testAddingTextFilesDirectly() {
        let window = app.windows["Window"]
        waitForTerminalToContain("Active Project: General")
        
        let addTextButton = window.buttons["Add Text"]
        let popover = addTextButton.popovers.firstMatch
        let textField = popover.children(matching: .textField).element

        addTextButton.click()
        textField.typeText("Short text.")
        popover.buttons["Save"].click()
        
        waitForTerminalToContain("“Short text.” staged in “General”")
        XCTAssert(window.staticTexts["Short text."].exists)

        addTextButton.click()
        textField.typeText("https://powderhouse.org/")
        popover.buttons["Save"].click()
        waitForTerminalToContain("“Powderhouse Studios — Come invent the fut—“ staged in “General”")

        addTextButton.click()
        textField.typeText("Some text that is longer than 20 characters so it will have to truncate.")
        popover.buttons["Save"].click()
        waitForTerminalToContain("“Some text that is longer than 20 characte—“ staged in “General”")
    }

    func waitForElementToAppear(_ element: XCUIElement) -> Bool {
        let predicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate,
                                                    object: element)
        
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        return result == .completed
    }
    
    func assertTerminalContains(_ text: String) {
        let terminal = app.textViews["terminal"]
        let terminalText = terminal.value as? String ?? ""
        XCTAssertNotNil(terminalText.range(of: text), "The terminal does not contain the text: \(text)")
    }
    
    func waitForTerminalToContain(_ text: String) {
        let terminal = app.textViews["terminal"]

        let contains = NSPredicate(format: "value contains[c] %@", text)
            
        let subsitutedContains = contains.withSubstitutionVariables(["text": text])
        
        expectation(for: subsitutedContains, evaluatedWith: terminal, handler: nil)
        waitForExpectations(timeout: 30, handler: nil)
    }
}
