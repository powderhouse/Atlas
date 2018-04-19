//
//  ProjectButton.swift
//  AtlasApp
//
//  Created by Jared Cosulich on 4/14/18.
//

import Cocoa
import AtlasCore

class ProjectButton: NSCollectionViewItem {

    @IBOutlet weak var button: NSButton!
    
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
            button.title = project!.name
            dropView.project = project!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        button.wantsLayer = true
    }
    
    @IBAction func select(_ sender: Any) {
        if let projectName = project?.name {
            var selectedProject: String? = projectName
            if button.layer?.backgroundColor == NSColor.red.cgColor {
                button.layer?.backgroundColor = NSColor.white.cgColor
                Terminal.log("Removing filter for \(projectName)")
                selectedProject = nil
            } else {
                button.layer?.backgroundColor = NSColor.red.cgColor
                Terminal.log("Filtering for \(projectName)")
            }
            
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: "filter-project"),
                object: nil,
                userInfo: ["projectName": selectedProject]
            )
        }
    }
    
    
}
