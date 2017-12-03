 //
//  GitTests.swift
//  atlasTests
//
//  Created by Jared Cosulich on 11/22/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import XCTest
@testable import atlas

class GitTests: XCTestCase {
    
    var directory: URL!
    var testGit: Git!
    var actualGit: Git!
    
    let remoteUser = "atlastest"
    let remotePassword = "1a2b3c4d"

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        directory = FileSystem.createDirectory("testGit")
        let fileManager = FileManager.default
        var isDir : ObjCBool = true
        XCTAssert(fileManager.fileExists(atPath: directory.path, isDirectory: &isDir), "\(directory) not created")
        
        testGit = Git(directory!,
                      username: "test", password: "1234",
                      atlasProcessFactory: MockProcessFactory())
        actualGit = Git(directory!, username: remoteUser, password: remotePassword)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: directory!)
        } catch {
            print("FAILED TO DELETE: \(error)")
        }
    }
    
    func testInit_noCredentialsProvidedAndNoPlistPresent() {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: directory!)
        } catch {
            print("FAILED TO DELETE: \(error)")
        }
        
        let newGit = Git(directory!)
        XCTAssertNil(newGit)
    }
    
    func testInit_noCredentialsProvidedAndPlistPresent() {
        
    }
    
    func testInit_credentialsProvided() {
        XCTAssertNotNil(actualGit)
        
        let filePath = "\(directory.path)/github.json"
        let fileManager = FileManager.default
        var isFile : ObjCBool = false
        XCTAssert(fileManager.fileExists(atPath: filePath, isDirectory: &isFile), "No github json found")        
    }
    
    func testSetCredentials() {
        actualGit.setCredentials(username: remoteUser, password: remotePassword)
        
        let filePath = "\(directory.path)/github.json"
        let fileManager = FileManager.default
        var isFile : ObjCBool = false
        XCTAssert(fileManager.fileExists(atPath: filePath, isDirectory: &isFile), "No github json found")
    }

    func testGetCredentials() {
        actualGit.setCredentials(username: remoteUser, password: remotePassword)
        let credentials = actualGit.getCredentials(username: remoteUser, password: remotePassword)
        XCTAssertEqual(credentials["username"], remoteUser)
        XCTAssertNotNil(credentials["token"])
    }

    func testStatus__notYetInitialized__actual() {
        XCTAssertNil(actualGit.status())
    }

    func testInit__actual() {
        initialize(clean: true)
    }

    func testAddNothing__actual() {
        initialize(clean: true)

        let preStatus = actualGit.status()
        XCTAssert(preStatus?.range(of: "nothing to commit") != nil)
        XCTAssert(preStatus?.range(of: "Changes to be committed") == nil)

        XCTAssert(actualGit.add())

        let postStatus = actualGit.status()
        XCTAssert(postStatus?.range(of: "nothing to commit") != nil)
        XCTAssert(postStatus?.range(of: "Changes to be committed") == nil)
}

    func testAdd__actual() {
        initialize()
        
        let preStatus = actualGit.status()
        XCTAssert(preStatus?.range(of: "index.html") != nil)
        XCTAssert(preStatus?.range(of: "nothing added to commit") != nil)

        XCTAssert(preStatus?.range(of: "Changes to be committed") == nil)
        XCTAssert(preStatus?.range(of: "new file:") == nil)

        XCTAssert(actualGit.add())
        
        let postStatus = actualGit.status()
        XCTAssert(postStatus?.range(of: "Changes to be committed") != nil)
        XCTAssert(postStatus?.range(of: "new file:   index.html") != nil)
    }
    
    func testCommit__actual() {
        initialize()
        
        XCTAssert(actualGit.add())
        
        let commit = actualGit.commit()
        XCTAssert(commit.range(of: "1 file changed, 0 insertions(+), 0 deletions(-)") != nil)
    }
    
    func testInitGitHub() {
        initialize()
        let results = actualGit.initGitHub()!
        let gitUrl = results["clone_url"] as! String
        XCTAssertEqual(gitUrl, "https://github.com/atlastest/testGit.git")
        
        actualGit.removeGitHub()
    }
    
    func testPushToGitHub() {
        initialize()
        _ = actualGit.initGitHub()
        
        XCTAssert(actualGit.add())
        
        let commit = actualGit.commit()
        XCTAssert(commit.range(of: "1 file changed, 0 insertions(+), 0 deletions(-)") != nil)

        actualGit.pushToGitHub()
        
        let status = actualGit.status()
        XCTAssert(status?.range(of: "Your branch is up-to-date") != nil)

        actualGit.removeGitHub()
    }

    func initialize(clean: Bool=false) {
        XCTAssertNil(actualGit.status())
        _ = actualGit.runInit()
        
        let status = actualGit.status()
        XCTAssert(status?.range(of: "On branch master") != nil)
        XCTAssert(status?.range(of: "Initial commit") != nil)
        XCTAssert(status?.range(of: "nothing to commit") != nil)
        
        if (clean) {
            return
        }
        
        let filePath = "\(directory.path)/index.html"
        _ = Glue.runProcess("/usr/bin/touch", arguments: [filePath])
        
        let fileManager = FileManager.default
        var isFile : ObjCBool = false
        XCTAssert(fileManager.fileExists(atPath: filePath, isDirectory: &isFile), "No file at \(filePath)")
    }
    
}
