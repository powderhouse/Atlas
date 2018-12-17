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
        addProject(app, name: projectName)

        let newProject = app.groups["\(projectName)-staged"]
        waitForTerminalToContain("Added project: \(projectName)")
        XCTAssert(waitForElementToAppear(newProject), "Unable to find new project")
    }

    func testFunkyProjectName() {
        login(app)

        let projectName = "\\\"\\\"\"A Project\\\"\\\"\""
        addProject(app, name: projectName)

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
        addProject(app, name: projectName)
        
        let filename = "indexfile.html"
        let commitMessage = "A commit message"
        stage(app, projectName: projectName, filename: filename)

        commit(app, projectName: projectName, commitMessage: commitMessage)
        waitForTerminalToContain("Files synced to S3.")
        
        let log = app.collectionViews["LogView"]
        XCTAssert(log.staticTexts[commitMessage].exists, "Unable to find \(commitMessage)")

        let projectStagingArea = app.groups["\(projectName)-staged"]
        projectStagingArea.buttons["x"].click()

        clickAlertButton("Delete")
        
        XCTAssert(waitForElementToDisappear(projectStagingArea))
        XCTAssertFalse(projectStagingArea.exists, "Can still find project staging area")
        XCTAssertFalse(log.staticTexts[commitMessage].exists, "Can still find commit message")
    }
    
    func testAddNote() {
        let note = "This is my note."
        login(app)
        
        let projectName = "Project"
        addProject(app, name: projectName)
        
        let projectStagingArea = app.groups["\(projectName)-staged"]
        projectStagingArea.buttons["+"].click()
        
        let noteDialog = projectStagingArea.popovers.firstMatch
        let noteMessageArea = noteDialog.textFields["Your note goes here"]
        noteMessageArea.click()
        noteMessageArea.typeText(note)
        noteDialog.buttons["Save"].click()
        
        waitForTerminalToContain("added to \(projectName)")
        
        if let output = app.textViews["TerminalView"].value as? String {
            let lines = output.components(separatedBy: "\n").filter { $0.contains("Note") }
            if let filename = lines.last?.replacingOccurrences(of: "Note, ", with: "")
                .replacingOccurrences(of: ", added to \(projectName)", with: "") {
                XCTAssert(projectStagingArea.staticTexts[filename].exists, "Unable to find \(filename)")
            } else {
                XCTAssert(false, "Unable to find filename")
            }
        }
    }
    
}
