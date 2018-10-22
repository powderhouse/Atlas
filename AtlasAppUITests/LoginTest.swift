//
//  AtlasAppUITests.swift
//  AtlasAppUITests
//
//  Created by Jared Cosulich on 3/12/18.
//

import XCTest
import AtlasCore

class LoginTest: AtlasUITestCase {
            
    func testLogin() {
        login(app)

        waitForTerminalToContain("Account: \(username)")
        waitForTerminalToContain("\(username)/\(AtlasCore.originName)")
    }
    
    func testBadLogin() {
        let accountModal = app.dialogs["Account Controller"]
        XCTAssert(accountModal.staticTexts["Welcome!"].exists)
        
        let usernameField = accountModal.textFields["GitHub Username"]
        usernameField.click()
        usernameField.typeText("BADUSERNAME")
        
        let emailField = accountModal.textFields["GitHub Email"]
        emailField.click()
        emailField.typeText("BADEMAIL@TEST.COM")
        
        let passwordSecureTextField = accountModal.secureTextFields["GitHub Password"]
        passwordSecureTextField.click()
        passwordSecureTextField.typeText("BAD PASSWORD")
        
        accountModal.buttons["Save"].click()

        let accountModal2 = app.dialogs["Account Controller"]
        waitForStaticText(accountModal2, text: "Authentication Error\nPlease check your GitHub credentials.")

        let usernameField2 = accountModal2.textFields["GitHub Username"]
        usernameField2.doubleClick()
        usernameField2.typeText(username)
        
        let emailField2 = accountModal2.textFields["GitHub Email"]
        emailField2.doubleClick()
        var deleteString = String()
        if let value = emailField2.value as? String {
            for _ in value {
                deleteString += XCUIKeyboardKey.delete.rawValue
            }
        }
        emailField2.typeText(deleteString)
        emailField2.typeText(email)
        
        let passwordSecureTextField2 = accountModal2.secureTextFields["GitHub Password"]
        passwordSecureTextField2.doubleClick()
        passwordSecureTextField2.typeText(password!)

        accountModal2.buttons["Save"].click()
        waitForTerminalToContain("https://github.com/atlasapptests/Atlas")
    }
    
}
