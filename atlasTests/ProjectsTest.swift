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
        
        Configuration.atlasDirectory = NSTemporaryDirectory()
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

        let stagingFolderPath = newFolder.appendingPathComponent("staging").path
        let stagingFolder = fileManager.fileExists(
            atPath: stagingFolderPath,
            isDirectory: &isDir
        )
        XCTAssertTrue(stagingFolder, "Staging folder was not successfully created at \(stagingFolderPath)")
    }
    
    func testCreateFolder_withExistingFolder() {
        _ = projects.create("project")

        let stagedFilePath = "\(projectsDirectory.path)/project/staging/staged.txt"
        _ = Glue.runProcess("touch", arguments: [stagedFilePath])

        let filePath = "\(projectsDirectory.path)/project/file.txt"
        _ = Glue.runProcess("touch", arguments: [filePath])
        
        let fileManager = FileManager.default
        var isDir : ObjCBool = false

        XCTAssert(fileManager.fileExists(atPath: filePath, isDirectory: &isDir), "No file at \(stagedFilePath)")
        XCTAssert(fileManager.fileExists(atPath: filePath, isDirectory: &isDir), "No file at \(filePath)")

        XCTAssertNotNil(projects.create("project"))

        XCTAssert(fileManager.fileExists(atPath: filePath, isDirectory: &isDir), "No file at \(stagedFilePath)")
        XCTAssert(fileManager.fileExists(atPath: filePath, isDirectory: &isDir), "No file at \(filePath)")
}
    
    func testProjects() {
        let filePath = "\(projectsDirectory.path)/index.html"
        _ = Glue.runProcess("touch", arguments: [filePath])
        
        let fileManager = FileManager.default
        var isFile : ObjCBool = false
        XCTAssert(fileManager.fileExists(atPath: filePath, isDirectory: &isFile), "No file at \(filePath)")
        
        _ = projects.create("Project One")
        _ = projects.create("Project Two")
        _ = projects.create("Project Three")
        let names = ["Project One", "Project Three", "Project Two"]
        XCTAssertEqual(names, projects.names())
        XCTAssertEqual(names, projects.list().map { $0.name })
    }
    
    func testSetActive() {
        _ = projects.create("Project One")
        _ = projects.create("Project Two")
        _ = projects.create("Project Three")
        
        projects.setActive("Project Two")
        XCTAssertEqual("Project Two", projects.active?.name)
    }
    
    func testActiveProject() {
        _ = projects.create("Project One")
        let projectTwoDirectory = projects.create("Project Two")
        _ = projects.create("Project Three")

        let filePath = "\(projectTwoDirectory!.path)/staging/ProjectTwoFileA.txt"
        _ = Glue.runProcess("touch", arguments: [filePath])

        let secondFilePath = "\(projectTwoDirectory!.path)/staging/ProjectTwoFileB.txt"
        _ = Glue.runProcess("touch", arguments: [secondFilePath])

        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        XCTAssert(fileManager.fileExists(atPath: filePath, isDirectory: &isDir), "No file at \(filePath)")
        XCTAssert(fileManager.fileExists(atPath: secondFilePath, isDirectory: &isDir), "No file at \(filePath)")

        projects.setActive("Project Two")
        XCTAssertEqual(2, projects.active?.stagedFiles.count)
        XCTAssertEqual(["ProjectTwoFileA.txt", "ProjectTwoFileB.txt"], (projects.active?.stagedFiles.sorted())!)
    }
    
}
