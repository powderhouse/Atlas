//
//  ProjectButtonViewItem.swift
//  atlas
//
//  Created by Jared Cosulich on 1/8/18.
//  Copyright © 2018 Powderhouse Studios. All rights reserved.
//

import Cocoa

class ProjectButtonViewItem: NSCollectionViewItem {

    @IBOutlet weak var projectButton: NSButton!
    
    var filePath: String?
    
    var window: NSWindow?
    
    var project: Project? {
        didSet {
            guard project != nil else { return }
            projectButton.title = project!.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }

    @IBAction func click(_ sender: NSButton) {
        guard project != nil else { return }
        guard filePath != nil else { return }
        project!.stageFile(URL(fileURLWithPath: filePath!))
        window?.close()
    }
}
