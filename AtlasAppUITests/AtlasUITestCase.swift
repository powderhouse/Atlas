//
//  Helper.swift
//  AtlasAppUITests
//
//  Created by Jared Cosulich on 3/14/18.
//

import Cocoa
import XCTest
import AtlasCore

class AtlasUITestCase: XCTestCase {

    let username = "atlasapptests"
    let email = "atlasapptests@puzzleschool.com"
//    let password = "1a2b3c4d"
    let repository = "AtlasTests"
    
    var app: XCUIApplication!
    var testDirectory: URL!

    override func setUp() {
        app = XCUIApplication()
        
        app.terminate()

        super.setUp()
        
        app.launchEnvironment["TESTING"] = "true"

        continueAfterFailure = false
        app.activate()
    }
    
    override func tearDown() {
        reset()
        super.tearDown()
    }
    
    func reset() {
//        while FileSystem.fileExists(testDirectory, isDirectory: true) {
//            _ = Glue.runProcess(
//                "chmod",
//                arguments: ["-R", "u+w", testDirectory.path],
//                currentDirectory: testDirectory.deletingLastPathComponent()
//            )
//            _ = FileSystem.deleteDirectory(testDirectory)
//        }
    }

    func waitForElementToAppear(_ element: XCUIElement) -> Bool {
        let predicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        return result == .completed
    }

    func waitForElementToDisappear(_ element: XCUIElement) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        return result == .completed
    }

    func assertTerminalContains(_ text: String) {
        let terminal = app.textViews["TerminalView"]
        let terminalText = terminal.value as? String ?? ""
        XCTAssertNotNil(terminalText.range(of: text), "The terminal does not contain the text: \(text)")
    }

    func assertTerminalDoesNotContain(_ text: String) {
        let terminal = app.textViews["TerminalView"]
        let terminalText = terminal.value as? String ?? ""
        XCTAssertNil(terminalText.range(of: text), "The terminal contains the text: \(text)")
    }
    
    func waitForTerminalToContain(_ text: String) {
        let terminalView = app.textViews["TerminalView"]
        waitForElementToContain(terminalView, text: text)
    }
    
    func waitForElementToContain(_ element: XCUIElement, text: String) {
        let contains = NSPredicate(format: "value contains[c] %@", text)
        
        let subsitutedContains = contains.withSubstitutionVariables(["text": text])
        
        expectation(for: subsitutedContains, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func login(_ app: XCUIApplication) {
        let accountModal = app.dialogs["Account Controller"]
        XCTAssert(accountModal.staticTexts["Welcome!"].exists)
        
        let usernameField = accountModal.textFields["GitHub Username"]
        usernameField.click()
        usernameField.typeText(username)

        let emailField = accountModal.textFields["GitHub Email"]
        emailField.click()
        emailField.typeText(email)

//        let passwordSecureTextField = accountModal.secureTextFields["GitHub Password"]
//        passwordSecureTextField.click()
//        passwordSecureTextField.typeText(password)
        
        accountModal.buttons["Save"].click()
        waitForTerminalToContain("Added project: General")
    }
    
    func stage(_ app: XCUIApplication, projectName: String, filename: String) {
        let terminal = app.textFields["TerminalInput"]        
        
        waitForTerminalToContain("Added project: General")

        terminal.click()
        terminal.typeText("pwd\n")
        if let output = app.textViews["TerminalView"].value as? String {
            if let dir = output.components(separatedBy: "\n").last {
                terminal.typeText("touch ../\(filename)\n")
                terminal.typeText("stage -f \(dir)/../\(filename) -p \(projectName)\n")
            }
        }
        
        waitForTerminalToContain("Successfully staged files in \(projectName)")
        
        terminal.typeText("rm \(filename)\n")
    }
    
    func commit(_ app: XCUIApplication, projectName: String, commitMessage: String) {
        let projectStaged = app.groups["\(projectName)-staged"]
        projectStaged.buttons["Commit"].click()
        
        let commitDialog = projectStaged.popovers.firstMatch
        let commitMessageArea = commitDialog.textFields["Why are you submitting these files?"]
        commitMessageArea.click()
        commitMessageArea.typeText(commitMessage)
        commitDialog.buttons["Commit"].click()
        
        waitForTerminalToContain("Files successfully committed.")
    }
}

