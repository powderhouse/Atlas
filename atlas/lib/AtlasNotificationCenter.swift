//
//  AtlasNotificationCenter.swift
//  atlas
//
//  Created by Jared Cosulich on 12/21/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Foundation

protocol AtlasNotificationCenter {
    func addObserver(forName name: NSNotification.Name?,
                     object obj: Any?,
                     queue: OperationQueue?,
                     using block: @escaping (Notification) -> Void) -> NSObjectProtocol
    
    func post(name aName: NSNotification.Name,
              object anObject: Any?,
              userInfo aUserInfo: [AnyHashable : Any]?)
    
    func post(name aName: NSNotification.Name,
              object anObject: Any?)
}

extension NotificationCenter: AtlasNotificationCenter {
}

