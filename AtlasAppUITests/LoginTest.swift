//
//  AtlasAppUITests.swift
//  AtlasAppUITests
//
//  Created by Jared Cosulich on 3/12/18.
//

import XCTest
import AtlasCore

class LoginTest: AtlasUITestCase {
            
    func testLogin() {
        login(app)

        waitForTerminalToContain("Account: \(username)")
        waitForTerminalToContain("\(username)/\(AtlasCore.originName)")
    }
    
}
