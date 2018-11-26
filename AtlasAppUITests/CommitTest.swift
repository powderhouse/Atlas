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
        let commitMessage = "A commit message"
        stage(app, projectName: projectName, filename: filename1)
        stage(app, projectName: projectName, filename: filename2)
        
        commit(app, projectName: projectName, commitMessage: commitMessage)
        
        let projectStagingArea = app.collectionViews["General-staged-files"]
        _ = waitForElementToDisappear(projectStagingArea.staticTexts[filename1])
        XCTAssertFalse(projectStagingArea.staticTexts[filename1].exists, "\(filename1) still exists in staging area")
        
        let log = app.collectionViews["LogView"]
        _ = waitForElementToAppear(log.staticTexts["\(commitMessage)\n"])
        XCTAssert(log.staticTexts["\(commitMessage)\n"].exists, "Unable to find \(commitMessage)")
        XCTAssert(log.staticTexts[projectName].exists, "Unable to find \(projectName)")
        XCTAssert(log.links["\(filename1)\n"].exists, "Unable to find \(filename1) link")
        XCTAssert(log.links[filename2].exists, "Unable to find \(filename2) link")
        
        log.buttons["x"].click()
        clickAlertButton("Remove")
        waitForSyncToComplete()
        
        XCTAssertFalse(log.staticTexts["\(commitMessage)\n"].exists, "Still finding \(commitMessage)")
        XCTAssertFalse(log.staticTexts[projectName].exists, "Still finding \(projectName)")
        XCTAssertFalse(log.links[filename1].exists, "Still finding \(filename1) link")
        XCTAssertFalse(log.links[filename2].exists, "Still finding \(filename2) link")
    }
    
}


