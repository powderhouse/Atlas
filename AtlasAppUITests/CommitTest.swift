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
    
}


