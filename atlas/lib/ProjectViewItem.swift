//
//  ProjectViewItem.swift
//  atlas
//
//  Created by Jared Cosulich on 12/7/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Cocoa

class ProjectViewItem: NSCollectionViewItem {
    
    @IBOutlet weak var label: NSTextField!
    
    @IBOutlet weak var dropView: DropView! {
        didSet {
            guard project != nil else { return }
            dropView.project = project
        }
    }
    
    var project: Project? {
        didSet {
            guard dropView != nil else { return }
            guard project != nil else { return }
            label.stringValue = project!.name
            dropView.project = project!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
    
}
