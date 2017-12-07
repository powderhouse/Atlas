//
//  ProjectsTest.swift
//  atlasTests
//
//  Created by Jared Cosulich on 12/6/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import XCTest
@testable import atlas

class ProjectsTests: XCTestCase {
    
    var projectsDirectory: URL!
    var projects: Projects!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        Configuration.atlasDirectory = "AtlasTest"
        projectsDirectory = FileSystem.baseDirectory().appendingPathComponent(
            "ProjectsTest",
            isDirectory: true
        )

        let fileManager = FileManager.default
        
        do {
            try fileManager.createDirectory(
                at: projectsDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            print("Unable to create projectsDirectory: \(projectsDirectory)")
        }
        
        projects = Projects(projectsDirectory)
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
    
    func testCreate() {
        let fileManager = FileManager.default
        var isDir : ObjCBool = true
        
        let newFolder = projectsDirectory.appendingPathComponent("project")
        
        let prefolder = fileManager.fileExists(
            atPath: newFolder.path,
            isDirectory: &isDir
        )
        
        XCTAssertFalse(prefolder, "Project already exists")
        
        _ = projects.create("project")
        
        let folder = fileManager.fileExists(
            atPath: newFolder.path,
            isDirectory: &isDir
        )
        XCTAssertTrue(folder, "Project was not successfully created")
    }
    
    func testCreateFolder_withExistingFolder() {
        _ = projects.create("project")
        XCTAssertNotNil(projects.create("project"))
    }
    
    func testProjects() {
        let filePath = "\(projectsDirectory.path)/index.html"
        _ = Glue.runProcess("/usr/bin/touch", arguments: [filePath])
        
        let fileManager = FileManager.default
        var isFile : ObjCBool = false
        XCTAssert(fileManager.fileExists(atPath: filePath, isDirectory: &isFile), "No file at \(filePath)")
        
        _ = projects.create("Project One")
        _ = projects.create("Project Two")
        _ = projects.create("Project Three")
        XCTAssertEqual(projects.list(), ["Project One", "Project Three", "Project Two"])
    }
    
}
