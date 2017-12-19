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
    
        Configuration.atlasDirectory = NSTemporaryDirectory()
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
        XCTAssert(baseDirectory.range(of: "Atlas") != nil, "\(baseDirectory) does not contain 'Atlas'")
    }
    
    func testCreateDirectory() {
        let fileManager = FileManager.default
        var isDir : ObjCBool = false

        let mainFolder = FileSystem.baseDirectory()
        let newFolder = mainFolder.appendingPathComponent("folder")

        let prefolder = fileManager.fileExists(
            atPath: newFolder.path,
            isDirectory: &isDir
        )
        
        XCTAssertFalse(prefolder, "Folder already exists")
        
        _ = FileSystem.createDirectory(newFolder)
        
        let folder = fileManager.fileExists(
            atPath: newFolder.path,
            isDirectory: &isDir
        )
        XCTAssertTrue(folder, "Folder was not successfully created")
    }

    func testCreateFolder_withExistingFolder() {
        let url = FileSystem.baseDirectory().appendingPathComponent("NewFolder", isDirectory: true)
        _ = FileSystem.createDirectory(url)
        XCTAssertNotNil(FileSystem.createDirectory(url))
    }
}
