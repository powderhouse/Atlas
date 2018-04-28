//
//  AddProjectTest.swift
//  AtlasAppUITests
//
//  Created by Jared Cosulich on 4/3/18.
//

import XCTest

class AddProjectTest: AtlasUITestCase {
    
    func testAddProject() {
        login(app)

        let projectName = "A Project"
        app.buttons["+"].click()
        let projectTextField = app.popovers.textFields["Project Name"]
        projectTextField.typeText(projectName)
        app.popovers.buttons["Save"].click()
        
        let newProject = app.groups["\(projectName)-staged"]
        waitForTerminalToContain("Added project: \(projectName)")
        XCTAssert(waitForElementToAppear(newProject), "Unable to find new project")
    }
    
    func testFunkyProjectName() {
        login(app)
        
        let projectName = "\\\"\\\"\"A Project\\\"\\\"\""
        app.buttons["+"].click()
        let projectTextField = app.popovers.textFields["Project Name"]
        projectTextField.typeText(projectName)
        app.popovers.buttons["Save"].click()
        
        let newProject = app.groups["\(projectName)-staged"]
        waitForTerminalToContain("Added project: \(projectName)")
        XCTAssert(waitForElementToAppear(newProject), "Unable to find new project")
        
        app.buttons["<"].click()
        
        XCTAssert(app.collectionViews.buttons[projectName].exists)

        app.buttons[">"].click()

        XCTAssert(app.groups["\(projectName)-staged"].staticTexts[projectName].exists)
    }
    
}
