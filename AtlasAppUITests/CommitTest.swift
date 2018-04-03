//
//  CommitTest.swift
//  AtlasAppUITests
//
//  Created by Jared Cosulich on 4/3/18.
//


import XCTest

class CommitTest: AtlasUITestCase {
    
    func testCommitFile() {
        login(app)
        
        let projectName = "General"
        let filename = "indexfile.html"
        let commitMessage = "A commit message"
        stage(app, projectName: projectName, filename: filename)
        
        let projectStaged = app.groups["General-staged"]
        projectStaged.buttons["Commit"].click()
        
        let commitDialog = projectStaged.popovers.firstMatch
        let commitMessageArea = commitDialog.textFields["Why are you submitting these files?"]
        commitMessageArea.click()
        commitMessageArea.typeText(commitMessage)
        commitDialog.buttons["Commit"].click()

        waitForTerminalToContain("Files successfully committed.")
        
        
        XCTAssert(app/*@START_MENU_TOKEN@*/.collectionViews["LogView"].staticTexts["A commit message\n"]/*[[".splitGroups",".scrollViews.collectionViews[\"LogView\"]",".groups.matching(identifier: \"CommitViewItem\").staticTexts[\"A commit message\\n\"]",".staticTexts[\"A commit message\\n\"]",".collectionViews[\"LogView\"]"],[[[-1,4,2],[-1,1,2],[-1,0,1]],[[-1,4,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.exists)
        
        let log = app.collectionViews["LogView"]
        XCTAssert(log.staticTexts[commitMessage].exists, "Unable to find \(commitMessage)")
        XCTAssert(log.staticTexts[projectName].exists, "Unable to find \(projectName)")
        XCTAssert(log.staticTexts[filename].exists, "Unable to find \(filename)")
//        waitForElementToContain(log, text: commitMessage)
//        waitForElementToContain(log, text: projectName)
//        waitForElementToContain(log, text: filename)
    }
    
}


