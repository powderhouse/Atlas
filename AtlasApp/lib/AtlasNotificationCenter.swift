//
//  AtlasNotificationCenter.swift
//  AtlasApp
//
//  Created by Jared Cosulich on 3/14/18.
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


