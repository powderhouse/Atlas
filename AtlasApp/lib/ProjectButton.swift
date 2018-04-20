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
    
    override var isSelected: Bool {
        get {
            return dropView.layer?.backgroundColor == NSColor.black.cgColor
        }
        
        set(newValue) {
            dropView.layer?.backgroundColor = newValue ? NSColor.black.cgColor : NSColor.white.cgColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        initNotifications() 
    }
    
    func initNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "filter-project"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            if let projectName = notification.userInfo?["projectName"] as? String {
                if projectName == self.project?.name {
                    if self.isSelected {
                        Terminal.log("Removing filter for \(projectName)")
                    } else {
                        Terminal.log("Filtering for \(projectName)")
                    }
                    self.isSelected = !self.isSelected
                } else {
                    self.isSelected = false
                }
            }
        }
    }
    
    @IBAction func click(_ sender: Any) {
        if let projectName = project?.name {
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: "filter-project"),
                object: nil,
                userInfo: ["projectName": projectName]
            )
        }
    }
}
