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
    var git: Git!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        directory = FileSystem.createDirectory("testGit")
        git = Git(directory!, atlasProcessFactory: MockProcessFactory())
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
        
    }

    func testInit__actual() {
        let actualGit = Git(directory!)
        XCTAssertNil(actualGit.status())
        _ = actualGit.runInit()
        XCTAssert(actualGit.status()!.range(of: "On branch master") != nil)
    }

    
}
