//
//  GlueTests.swift
//  atlasTests
//
//  Created by Jared Cosulich on 11/19/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import XCTest
@testable import atlas


class TestProcess: Process {
    let process = Process()
    
    override var standardOutput: Any? {
        get { return "" }
        set {}
    }

    override var launchPath: String? {
        get { return "" }
        set(lp) { super.launchPath = lp }
    }

    override var arguments: [String]? {
        get { return [""] }
        set {}
    }
    
    override func launch() {
//        let p = Process()
//        p.wait
        print("LAUNCH: \(launchPath ?? "N/A")")
        super.launchPath = "/bin/ls"
        super.launch()
    }

    override func waitUntilExit() {
        super.waitUntilExit()
    }

}

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
        let config = GlueConfiguration(providedProcess: TestProcess(), providedPipe: Pipe())
        Glue.runProcess("command", arguments: [], config: config)
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
