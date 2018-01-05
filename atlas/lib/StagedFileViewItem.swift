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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
    
    @IBAction func remove(_ sender: NSButton) {
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: "remove-staged-file"),
            object: nil,
            userInfo: ["name": label.stringValue]
        )
    }
}
