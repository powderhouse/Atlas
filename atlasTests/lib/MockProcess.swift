//
//  MockProcess.swift
//  atlasTests
//
//  Created by Jared Cosulich on 11/22/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import XCTest
@testable import atlas

class MockProcess: AtlasProcess {
    var currentDirectoryURL: URL?
    
    var executableURL: URL?
    
    var arguments: [String]?
    
    var commandResults: [String: String] = [:]
    
    var output: String?
    
    func runAndWait() -> String {
        //        executableURL    URL?    "locate%20Homebrew -- ile:///Users/jcosulich/Library/Containers/com.powderhs.atlas/Data/"    some
        output = commandResults["executableURL"]!
        return commandResults["executableURL"]!
    }
}

class MockProcessFactory: AtlasProcessFactory {
    var processes: [MockProcess] = []
    
    init() {
    }
    
    func build() -> AtlasProcess {
        let process = MockProcess()
        processes.append(process)
        return process
    }
}
