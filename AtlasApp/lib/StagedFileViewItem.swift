//
//  StagedFileViewItem.swift
//  atlas
//
//  Created by Jared Cosulich on 12/11/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Cocoa
import AtlasCore

class StagedFileViewItem: NSCollectionViewItem {

    var project: Project!
    
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var selectCheck: NSButton!
    
    override var isSelected: Bool {
        get {
            return selectCheck.state == NSControl.StateValue.on
        }
        set(newValue) {
            selectCheck.state = (newValue ? NSControl.StateValue.on : NSControl.StateValue.off)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
    
    @IBAction func select(_ sender: NSButton) {
        let newState = selectCheck.state == NSControl.StateValue.off ? "unstaged" : "staged"
        
        if  project.changeState([label.stringValue], to: newState) {
            Terminal.log("Successfully \(newState) file.")
        } else {
            Terminal.log("There was an error changing the state of the file.")
        }
    }
    
    @IBAction func remove(_ sender: NSButton) {
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: "remove-staged-file"),
            object: nil,
            userInfo: ["name": label.stringValue]
        )
    }
}
