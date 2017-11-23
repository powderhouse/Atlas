//
//  GlueTests.swift
//  atlasTests
//
//  Created by Jared Cosulich on 11/19/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//


// THIS IS A WORK IN PROGRESS


import XCTest
@testable import atlas

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
        let output = Glue.runProcess("/usr/bin/git", arguments: ["-c", "ls"])
        XCTAssert(output.range(of: "usage: git") != nil, "\(output) should contain 'usage: git'")
    }

//    func testInstallHomebrew() {
//        let findProcess = MockProcess()
//        findProcess.commandResults["locate Homebrew"] = ""
//
//        let installProcess = MockProcess()
//        let installCommand = Glue.installCommands["homebrew"]!
//        installProcess.commandResults[installCommand] = "success"
//
//        Glue.installHomebrew(find: findProcess, install: installProcess)
//        XCTAssertEqual(installProcess.output, "success")
//    }
//
//    func testInstallHomebrew__alreadyInstalled() {
//        let findProcess = MockProcess()
//        let installProcess = MockProcess()
//        Glue.installHomebrew(find: findProcess, install: installProcess)
//        XCTAssertNil(installProcess.executableURL)
//    }
//
//    func testInstallS3Cmd() {
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
