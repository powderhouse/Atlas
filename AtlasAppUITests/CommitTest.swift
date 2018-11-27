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
        
        commit(app, projectName: projectName, commitMessage: commitMessage)
        
        let projectStagingArea = app.collectionViews["General-staged-files"]
        _ = waitForElementToDisappear(projectStagingArea.staticTexts[filename])
        XCTAssertFalse(projectStagingArea.staticTexts[filename].exists, "\(filename) still exists in staging area")
        
        let log = app.collectionViews["LogView"]
        XCTAssert(log.staticTexts["\(commitMessage)\n"].exists, "Unable to find \(commitMessage)")
        XCTAssert(log.staticTexts[projectName].exists, "Unable to find \(projectName)")
        XCTAssert(log.links[filename].exists, "Unable to find \(filename) link")
    }
    
    func testPurgeCommit() {
        login(app)
        
        let projectName = "General"
        let filename1 = "indexfile1.html"
        let filename2 = "indexfile2.html"
        let filename3 = "indexfile3.html"
        let commitMessage = "Commit"
        stage(app, projectName: projectName, filename: filename1)
        stage(app, projectName: projectName, filename: filename2)
        stage(app, projectName: projectName, filename: filename3)
        waitForSyncToComplete()
        
        commit(app, projectName: projectName, commitMessage: commitMessage)
        waitForSyncToComplete()
        
        let projectStagingArea = app.collectionViews["General-staged-files"]
        _ = waitForElementToDisappear(projectStagingArea.staticTexts[filename1])
        XCTAssertFalse(projectStagingArea.staticTexts[filename1].exists, "\(filename1) still exists in staging area")
        
        let log = app.collectionViews["LogView"]
        _ = waitForElementToAppear(log.staticTexts["\(commitMessage)\n"])
        XCTAssert(log.staticTexts["\(commitMessage)\n"].exists, "Unable to find \(commitMessage)")
        XCTAssert(log.staticTexts[projectName].exists, "Unable to find \(projectName)")
        XCTAssert(log.links[filename3].exists, "Unable to find \(filename3) link")
        
        log.textViews.children(matching: .link).matching(identifier: "x   ").element(boundBy: 2).click()
        clickAlertButton("Remove")
        waitForTerminalToContain("Successfully purged \(projectName)/committed/commit/\(filename3) from Atlas.")
        waitForSyncToComplete()

        XCTAssert(log.staticTexts["\(commitMessage)\n"].exists, "Unable to find \(commitMessage)")
        XCTAssert(log.staticTexts[projectName].exists, "Unable to find \(projectName)")
        XCTAssertFalse(log.links[filename3].exists, "Still finding \(filename3) link")

        log.buttons["x"].click()
        clickAlertButton("Remove")
        waitForSyncToComplete()
        waitForTerminalToContain("Successfully purged \(projectName)/committed/commit from Atlas.")
        
        XCTAssertFalse(log.staticTexts["\(commitMessage)\n"].exists, "Still finding \(commitMessage)")
        XCTAssertFalse(log.staticTexts[projectName].exists, "Still finding \(projectName)")
        XCTAssertFalse(log.links[filename2].exists, "Still finding \(filename2) link")
    }
    
}


