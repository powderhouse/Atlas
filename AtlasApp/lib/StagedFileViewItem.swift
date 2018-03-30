//
//  StagedFileViewItem.swift
//  atlas
//
//  Created by Jared Cosulich on 12/11/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Cocoa

class StagedFileViewItem: NSCollectionViewItem {

    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var selectCheck: NSButton!
    
    override var isSelected: Bool {
        get {
            return selectCheck.state == NSControl.StateValue.on
        }
        set(newValue) {
            selectCheck.state = (newValue ? NSControl.StateValue.on : NSControl.StateValue.off)
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: "staging-file-toggled"),
                object: nil
            )
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
    
    @IBAction func select(_ sender: NSButton) {
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: "staging-file-toggled"),
            object: nil
        )
    }
    
    @IBAction func remove(_ sender: NSButton) {
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: "remove-staged-file"),
            object: nil,
            userInfo: ["name": label.stringValue]
        )
    }
}
