//
//  GlueTests.swift
//  atlasTests
//
//  Created by Jared Cosulich on 11/19/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import XCTest
@testable import atlas


//class MockProcess: AtlasProcess {
//}

class GlueTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRunProcess() {
        let output = Glue.runProcess("/bin/bash", arguments: ["-c", "ls"])
        XCTAssert(output.range(of: "Desktop") != nil)
    }
    
    func testInstallHomebrew() {
//        let config = GlueConfiguration(atlasProcess: MockProcess(), providedPipe: Pipe())
//        Glue.runProcess("command", arguments: [], config: config, completion: {
//            result in
//            print(result)
//        })
    }
    
    func testInstallS3Cmd() {
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
