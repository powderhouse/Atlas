//
//  FileSystemTests.swift
//  atlasTests
//
//  Created by Jared Cosulich on 11/16/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import XCTest
@testable import atlas

class FileSystemTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBaseDirectory() {
        let baseDirectory = FileSystem.baseDirectory().relativeString
        XCTAssert(baseDirectory.range(of: "com.powderhs.atlas") != nil)
    }
    
    func testCreateFolder() {
        let fileManager = FileManager.default
        var isDir : ObjCBool = false

        let mainFolderPath = FileSystem.baseDirectory().appendingPathComponent("Atlas")

        do {
            try fileManager.removeItem(at: mainFolderPath)
        } catch {}

        let prefolder = fileManager.fileExists(
            atPath: mainFolderPath.path,
            isDirectory: &isDir
        )
        
        XCTAssertFalse(prefolder, "Folder already exists")
        
        _ = FileSystem.createDirectory("Atlas")
        
        let folder = fileManager.fileExists(
            atPath: mainFolderPath.path,
            isDirectory: &isDir
        )
        XCTAssertTrue(folder, "Folder was not successfully created")
    }

    func testCreateFolder_withExistingFolder() {
        _ = FileSystem.createDirectory("Atlas")
        XCTAssertTrue(FileSystem.createDirectory("Atlas"))
    }

}
