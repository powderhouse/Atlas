//
//  AppDelegate.swift
//  atlas
//
//  Created by Alec Resnick on 11/15/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Cocoa

struct Configuration {
    static var atlasDirectory = ProcessInfo.processInfo.environment["atlasDirectory"] ?? "Atlas"
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

