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

    func testUserDesktopDirectory() {
        let desktopDirectory = FileSystem.userDesktopDirectory().relativeString
        XCTAssert(desktopDirectory.range(of: "Desktop") != nil)
    }

}
