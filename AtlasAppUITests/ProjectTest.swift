//
//  AddProjectTest.swift
//  AtlasAppUITests
//
//  Created by Jared Cosulich on 4/3/18.
//

import XCTest

class ProjectTest: AtlasUITestCase {
    
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
        waitForTerminalToContain("A Project")
        XCTAssert(waitForElementToAppear(newProject), "Unable to find new project")

        app.buttons["<"].click()

        XCTAssert(app.collectionViews.buttons[projectName].exists)

        app.buttons[">"].click()

        XCTAssert(app.groups["\(projectName)-staged"].staticTexts[projectName].exists)
    }
    
    func testDeleteProject() {
        login(app)

        let projectName = "Project"
        app.buttons["+"].click()
        let projectTextField = app.popovers.textFields["Project Name"]
        XCTAssert(waitForElementToAppear(projectTextField))
        projectTextField.typeText(projectName)
        app.popovers.buttons["Save"].click()
        
        waitForTerminalToContain("Added project: \(projectName)")

        let filename = "indexfile.html"
        let commitMessage = "A commit message"
        stage(app, projectName: projectName, filename: filename)

        commit(app, projectName: projectName, commitMessage: commitMessage)
        waitForTerminalToContain("Files synced to S3.")
        
        let log = app.collectionViews["LogView"]
        XCTAssert(log.staticTexts["\(commitMessage)\n"].exists, "Unable to find \(commitMessage)")

        let projectStagingArea = app.groups["\(projectName)-staged"]
        projectStagingArea.buttons["x"].click()

        let button = app.buttons["Delete"].firstMatch
        XCTAssert(waitForElementToAppear(button))
        if button.exists {
            button.tap()
        }
        
        XCTAssert(waitForElementToDisappear(projectStagingArea))
        XCTAssertFalse(projectStagingArea.exists, "Can still find project staging area")
        XCTAssertFalse(log.staticTexts["\(commitMessage)\n"].exists, "Can still find commit message")
    }
    
}
