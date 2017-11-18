//
//  FileSystemTests.swift
//  atlasTests
//
//  Created by Jared Cosulich on 11/16/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import XCTest
@testable import atlas

struct Configuration {
    static let atlasDirectory = "AtlasTest"
}

class FileSystemTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        let fileManager = FileManager.default
        let mainFolder = FileSystem.baseDirectory()
        do {
            try fileManager.removeItem(at: mainFolder)
        } catch {}
        
        super.tearDown()
    }

    func testBaseDirectory() {
        let baseDirectory = FileSystem.baseDirectory().relativeString
        XCTAssert(baseDirectory.range(of: "com.powderhs.atlas") != nil)
    }
    
    func testCreateFolder() {
        let fileManager = FileManager.default
        var isDir : ObjCBool = false

        let mainFolder = FileSystem.baseDirectory()
        let newFolder = mainFolder.appendingPathComponent("folder")

        let prefolder = fileManager.fileExists(
            atPath: newFolder.path,
            isDirectory: &isDir
        )
        
        XCTAssertFalse(prefolder, "Folder already exists")
        
        _ = FileSystem.createDirectory("folder")
        
        let folder = fileManager.fileExists(
            atPath: newFolder.path,
            isDirectory: &isDir
        )
        XCTAssertTrue(folder, "Folder was not successfully created")
    }

    func testCreateFolder_withExistingFolder() {
        _ = FileSystem.createDirectory("directory")
        XCTAssertTrue(FileSystem.createDirectory("directory"))
    }
    
    func testAccount() {
        _ = FileSystem.createDirectory("test.example@example.com")
        XCTAssertEqual(FileSystem.account(), "test.example@example.com", "emails do not match") 
    }

}
