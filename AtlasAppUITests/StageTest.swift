//
//  ImportTest.swift
//  AtlasAppUITests
//
//  Created by Jared Cosulich on 4/2/18.
//

import XCTest

class StageTest: AtlasUITestCase {
    let filename = "indexfile.html"

    override func setUp() {
        super.setUp()
        
        login(app)
        
        stage(app, projectName: "General", filename: filename)
    }
    
    func testStagingFile() {
        let projectStagingArea = app.collectionViews["General-staged-files"]
        XCTAssert(projectStagingArea.staticTexts[filename].exists, "Unable to find \(filename)")
    }
    
    func testUnstagingFile() {
        let projectStagingArea = app.collectionViews["General-staged-files"]
        let file = projectStagingArea.groups["StagedFileViewItem"].children(matching: .checkBox).element
        file.click()
        
        waitForTerminalToContain("Successfully unstaged file.")

        let commitButton = app.groups["General-staged"].buttons["Commit"]
        XCTAssertFalse(commitButton.isEnabled)
    }
    
    func testRemovingStagedFile() {
        app.collectionViews["General-staged-files"].buttons["-"].click()
        waitForTerminalToContain("Successfully purged file from Atlas.")

        let commitButton = app.groups["General-staged"].buttons["Commit"]
        XCTAssertFalse(commitButton.isEnabled)
    }

    func testRemovingUnstagedFile() {
        let projectStagingArea = app.collectionViews["General-staged-files"]
        let file = projectStagingArea.groups["StagedFileViewItem"].children(matching: .checkBox).element
        file.click()
        
        waitForTerminalToContain("Successfully unstaged file.")

        let commitButton = app.groups["General-staged"].buttons["Commit"]
        XCTAssertFalse(commitButton.isEnabled)
        
        projectStagingArea.buttons["-"].click()
        waitForTerminalToContain("Successfully purged file from Atlas.")
        
        XCTAssertFalse(commitButton.isEnabled)
    }
    
    func testStagingUpdatesProjectButton() {
        app.buttons["<"].click()

        let stagedButton = app.groups["General-staged-button"]
        XCTAssert(stagedButton.staticTexts["1"].exists)

        stage(app, projectName: "General", filename: "indexfile2.html")

        XCTAssert(stagedButton.staticTexts["2"].exists)
    }

}

