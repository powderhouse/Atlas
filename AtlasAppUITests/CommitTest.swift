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
        _ = waitForElementToAppear(log.staticTexts[commitMessage])
        XCTAssert(log.staticTexts[commitMessage].exists, "Unable to find \(commitMessage)")
        XCTAssert(log.staticTexts[projectName].exists, "Unable to find \(projectName)")
        XCTAssert(log.buttons[filename].exists, "Unable to find \(filename) link")
    }
    
    func testPurgeCommit() {
        login(app)
        
        let projectName = "General"
        let filename1 = "indexfile1.html"
        let filename2 = "indexfile2.html"
        let filename3 = "indexfile3.html"
        let filename4 = "indexfile4.html"
        let commitMessage1 = "Commit1"
        let commitMessage2 = "Commit2"

        stage(app, projectName: projectName, filename: filename1)
        stage(app, projectName: projectName, filename: filename2)
        waitForSyncToComplete()

        commit(app, projectName: projectName, commitMessage: commitMessage1)
        waitForSyncToComplete()

        stage(app, projectName: projectName, filename: filename3)
        stage(app, projectName: projectName, filename: filename4)
        waitForSyncToComplete()
        
        commit(app, projectName: projectName, commitMessage: commitMessage2)
        waitForSyncToComplete()
        
        let projectStagingArea = app.collectionViews["General-staged-files"]
        _ = waitForElementToDisappear(projectStagingArea.staticTexts[filename1])
        XCTAssertFalse(projectStagingArea.staticTexts[filename1].exists, "\(filename1) still exists in staging area")
        
        let log = app.collectionViews["LogView"]
        _ = waitForElementToAppear(log.staticTexts[commitMessage2])
        XCTAssert(log.staticTexts[commitMessage2].exists, "Unable to find \(commitMessage2)")
        XCTAssert(log.staticTexts[projectName].exists, "Unable to find \(projectName)")
        XCTAssert(log.buttons[filename1].exists, "Unable to find \(filename1) link")
        
        log.groups[filename1].buttons["x"].click()
        clickAlertButton("Remove")
        waitForTerminalToContain("Successfully purged \(projectName)/committed/commit1/\(filename1) from Atlas.")
        waitForSyncToComplete()

        XCTAssert(log.staticTexts[commitMessage2].exists, "Unable to find \(commitMessage2)")
        XCTAssert(log.staticTexts[projectName].exists, "Unable to find \(projectName)")
        XCTAssertFalse(log.links[filename1].exists, "Still finding \(filename1) link")

        log.groups.matching(identifier: "CommitViewItem").element(boundBy: 0).buttons["delete-commit"].click()
        clickAlertButton("Remove")
        waitForSyncToComplete()
        waitForTerminalToContain("Successfully purged \(projectName)/committed/commit2/ from Atlas.")
        
        waitForNoStaticText(log, text: commitMessage2)
        XCTAssertFalse(log.staticTexts[commitMessage2].exists, "Still finding \(commitMessage2)")
        XCTAssert(log.staticTexts[commitMessage1].exists, "Unable to find \(commitMessage1)")
        XCTAssertFalse(log.links[filename4].exists, "Still finding \(filename4) link")
        XCTAssert(log.buttons[filename2].exists, "Unable to find \(filename2) link")
    }
    
}


