//
//  MockNotificationCenter.swift
//  atlasTests
//
//  Created by Jared Cosulich on 12/21/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//


import XCTest
@testable import atlas

class MockNotificationCenter: AtlasNotificationCenter {
    
    var postsCalled: [NSNotification.Name: Int] = [:]
    var lastPost: [String: Any] = [:]
    
    init() {
    }
    
    func addObserver(forName name: NSNotification.Name?, object obj: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> Void) -> NSObjectProtocol {
        return NSObject()
    }
    
    func post(name aName: NSNotification.Name, object anObject: Any?, userInfo aUserInfo: [AnyHashable : Any]?) {
        callPost(name: aName, object: anObject, userInfo: aUserInfo)
    }
    
    func post(name aName: NSNotification.Name, object anObject: Any?) {
        callPost(name: aName, object: anObject, userInfo: nil)
    }
    
    func callPost(name aName: NSNotification.Name, object anObject: Any?, userInfo aUserInfo: [AnyHashable : Any]?) {
        postsCalled[aName] = (postsCalled[aName] ?? 0) + 1
        lastPost = [
            "name": aName,
            "object": anObject ?? nil,
            "userInfo": aUserInfo ?? nil
        ]
    }
    
}

