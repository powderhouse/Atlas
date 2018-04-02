//
//  AtlasAppUITests.swift
//  AtlasAppUITests
//
//  Created by Jared Cosulich on 3/12/18.
//

import XCTest

class LoginTest: AtlasUITestCase {
            
    func testLogin() {
        login(app)
        
        waitForTerminalToContain("Account: \(Helper.username)")
        waitForTerminalToContain("GitHub Repository: https://github.com/\(Helper.username)/Atlas")
    }
    
}
