//
//  ImportTest.swift
//  AtlasAppUITests
//
//  Created by Jared Cosulich on 4/2/18.
//

import XCTest

class StageTest: AtlasUITestCase {
    
    func testStagingFile() {
        login(app)
        
        let filename = "indexfile.html"
        stage(app, projectName: "General", filename: filename)

        let projectStagingArea = app.collectionViews["General-staged-files"]
        XCTAssert(projectStagingArea.staticTexts[filename].exists, "Unable to find \(filename)")
    }
    
}

