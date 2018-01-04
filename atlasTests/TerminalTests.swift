//
//  TerminalTests.swift
//  atlasTests
//
//  Created by Jared Cosulich on 12/21/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import XCTest
@testable import atlas

class TerminalTests: XCTestCase {
    
    let notificationCenter = MockNotificationCenter()
    var terminal: Terminal!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let view = NSTextView()
        terminal = Terminal(view, notificationCenter: notificationCenter)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRunCommand() {
        terminal.runCommand("stage path/to/file")
        
        let stageCommand = NSNotification.Name(rawValue: "git-stage")
        XCTAssertEqual(1, notificationCenter.postsCalled[stageCommand])
        var userInfo = notificationCenter.lastPost["userInfo"] as? [String: String]
        XCTAssertEqual("path/to/file", userInfo?["path"])

        terminal.runCommand("stage \"path/to/file\"")
        XCTAssertEqual(2, notificationCenter.postsCalled[stageCommand])
        userInfo = notificationCenter.lastPost["userInfo"] as? [String: String]
        XCTAssertEqual("path/to/file", userInfo?["path"])

        let commitCommand = NSNotification.Name(rawValue: "git-commit")
        terminal.runCommand("commit \"commit message\"")
        XCTAssertEqual(1, notificationCenter.postsCalled[commitCommand])
        userInfo = notificationCenter.lastPost["userInfo"] as? [String: String]
        XCTAssertEqual("commit message", userInfo?["message"])

        let logCommand = NSNotification.Name(rawValue: "git-log-name-only")
        terminal.runCommand("atlas log")
        XCTAssertEqual(1, notificationCenter.postsCalled[logCommand])

        let rawCommand = NSNotification.Name(rawValue: "raw-command")
        terminal.runCommand("some_random_command -u with_parameters")
        XCTAssertEqual(1, notificationCenter.postsCalled[rawCommand])
        userInfo = notificationCenter.lastPost["userInfo"] as? [String: String]
        XCTAssertEqual("some_random_command -u with_parameters", userInfo?["command"])
    }
}
