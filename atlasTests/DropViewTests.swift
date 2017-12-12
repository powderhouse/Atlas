//
//  DropViewTests.swift
//  atlasTests
//
//  Created by Jared Cosulich on 12/12/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Foundation
import XCTest
@testable import atlas

class DropViewTests: XCTestCase {
    
    var dropView: DropView!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        dropView = DropView(coder: NSCoder())
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        super.tearDown()
    }
    
    func testInit() {
        XCTAssert(dropView != nil)
    }
}
