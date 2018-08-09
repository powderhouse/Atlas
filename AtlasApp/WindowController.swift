//
//  WindowController.swift
//  AtlasApp
//
//  Created by Jared Cosulich on 5/29/18.
//

import Cocoa
import AtlasCore

class WindowController: NSWindowController {
    
    let version = "0.3.2"
    
    @IBOutlet var atlasWindow: NSWindow!
    
    override func windowDidLoad() {
        atlasWindow.title = "Atlas (App: \(version), AtlasCore: \(AtlasCore.version))"
    }
    
}
