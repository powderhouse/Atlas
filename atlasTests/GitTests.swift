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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        directory = FileSystem.createDirectory("testGit")
        let fileManager = FileManager.default
        var isDir : ObjCBool = true
        XCTAssert(fileManager.fileExists(atPath: directory.path, isDirectory: &isDir), "\(directory) not created")
        
        testGit = Git(directory!, atlasProcessFactory: MockProcessFactory())
        actualGit = Git(directory!)
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
    
    func testAddRemote() {
        initialize()
        
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
