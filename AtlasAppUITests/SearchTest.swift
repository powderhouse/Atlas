//
//  SearchTest.swift
//  AtlasAppUITests
//
//  Created by Jared Cosulich on 5/25/18.
//

import XCTest

class SearchTest: AtlasUITestCase {
    
    func testSearchLog() {
        login(app)
        
        let projectName = "General"
        
        let filename = "indexfile.html"
        let commitMessage = "A commit message"
        stage(app, projectName: projectName, filename: filename)
        commit(app, projectName: projectName, commitMessage: commitMessage)

        let filename2 = "indexfile2.html"
        let commitMessage2 = "Another commit message"
        stage(app, projectName: projectName, filename: filename2)
        commit(app, projectName: projectName, commitMessage: commitMessage2)
        
        let searchText = app.textFields["search_text"].firstMatch
        let searchButton = app.buttons["search"].firstMatch
        searchText.click()
        searchText.typeText("another")
        searchButton.click()
        
        let log = app.collectionViews["LogView"]
        XCTAssert(log.staticTexts[projectName].exists, "Unable to find \(projectName)")

        XCTAssert(log.staticTexts["\(commitMessage2)\n"].exists, "Unable to find \(commitMessage2)")
        XCTAssert(log.links[filename2].exists, "Unable to find \(filename2) link")

        XCTAssertFalse(log.staticTexts["\(commitMessage)\n"].exists, "Still see \(commitMessage2)")
        XCTAssertFalse(log.links[filename].exists, "Still see \(filename2) link")
    }
    
    
    
}

