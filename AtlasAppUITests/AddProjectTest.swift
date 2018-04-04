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

        let projectName = "Project Name"
        app.buttons["+"].click()
        let projectTextField = app.popovers.textFields[projectName]
        projectTextField.typeText(projectName)
        app.popovers.buttons["Save"].click()
        
        let newProject = app.groups["\(projectName)-staged"]
        waitForTerminalToContain("Added project: \(projectName)")
        XCTAssert(waitForElementToAppear(newProject), "Unable to find new project")
    }
    
}
