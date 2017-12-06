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
    
        Configuration.atlasDirectory = "AtlasTest"
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
        XCTAssertNotNil(FileSystem.createDirectory("directory"))
    }
    
    func testProjects() {
        let directory = FileSystem.baseDirectory().deletingLastPathComponent()
        _ = FileSystem.createDirectory(FileSystem.atlasDirectory(), inDirectory: directory)
        
        let filePath = "\(FileSystem.baseDirectory().path)/index.html"
        _ = Glue.runProcess("/usr/bin/touch", arguments: [filePath])
        
        let fileManager = FileManager.default
        var isFile : ObjCBool = false
        XCTAssert(fileManager.fileExists(atPath: filePath, isDirectory: &isFile), "No file at \(filePath)")

        _ = FileSystem.createDirectory("Project One")
        _ = FileSystem.createDirectory("Project Two")
        _ = FileSystem.createDirectory("Project Three")
        XCTAssertEqual(FileSystem.projects(), ["Project One", "Project Three", "Project Two"])
    }

}
