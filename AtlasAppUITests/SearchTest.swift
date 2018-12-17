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
        let log = app.collectionViews["LogView"]

        searchText.click()
        searchText.typeText("another")
        
        XCTAssert(log.staticTexts[commitMessage2].exists, "Unable to find \(commitMessage2)")
        XCTAssert(log.links[filename2].exists, "Unable to find \(filename2) link")

        XCTAssertFalse(log.staticTexts[commitMessage].exists, "Still see \(commitMessage)")
        XCTAssertFalse(log.links[filename].exists, "Still see \(filename) link")

        searchText.click()
        searchText.typeText("another commit")
        
        XCTAssert(log.staticTexts[commitMessage2].exists, "Unable to find \(commitMessage2)")
        XCTAssert(log.links[filename2].exists, "Unable to find \(filename2) link")
        
        XCTAssert(log.staticTexts[commitMessage].exists, "Unable to find \(commitMessage)")
        XCTAssert(log.links[filename].exists, "Unable to find \(filename) link")

        searchText.click()
        searchText.typeText("\"another commit\"")
        
        XCTAssert(log.staticTexts[commitMessage2].exists, "Unable to find \(commitMessage2)")
        XCTAssert(log.links[filename2].exists, "Unable to find \(filename2) link")
        
        XCTAssertFalse(log.staticTexts[commitMessage].exists, "Still see \(commitMessage)")
        XCTAssertFalse(log.links[filename].exists, "Still see \(filename) link")

        searchText.click()
        searchText.typeText("index")
        
        XCTAssert(log.staticTexts[commitMessage2].exists, "Unable to find \(commitMessage2)")
        XCTAssert(log.links[filename2].exists, "Unable to find \(filename2) link")
        
        XCTAssert(log.staticTexts[commitMessage].exists, "Unable to find \(commitMessage)")
        XCTAssert(log.links[filename].exists, "Unable to find \(filename) link")

        searchText.click()
        searchText.typeText("indexfile2")
        
        XCTAssert(log.staticTexts[commitMessage2].exists, "Unable to find \(commitMessage2)")
        XCTAssert(log.links[filename2].exists, "Unable to find \(filename2) link")

        XCTAssertFalse(log.staticTexts[commitMessage].exists, "Still see \(commitMessage)")
        XCTAssertFalse(log.links[filename].exists, "Still see \(filename) link")
    }
    
}

