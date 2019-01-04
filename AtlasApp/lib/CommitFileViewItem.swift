//
//  CommitFileViewItem.swift
//  AtlasApp
//
//  Created by Jared Cosulich on 1/3/19.
//

import Cocoa
import AtlasCore

class CommitFileViewItem: NSCollectionViewItem {
    
    @IBOutlet weak var image: NSImageView!
    @IBOutlet weak var fileLink: NSTextField!
    @IBOutlet weak var removeButton: NSButton!
    
    var project: Project?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
    
    @IBAction func remove(_ sender: NSButton) {
        let a = NSAlert()
        a.messageText = "Remove this file?"
        a.informativeText = "Are you sure you would like to remove this file?"
        a.addButton(withTitle: "Remove")
        a.addButton(withTitle: "Cancel")
        
        a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                if let project = self.project {
                    let file = "\(project.name!)/\(Project.committed)/\(self.fileLink.stringValue)"
                    NotificationCenter.default.post(
                        name: NSNotification.Name(rawValue: "remove-file"),
                        object: nil,
                        userInfo: [
                            "file": file,
                            "projectName": project.name
                        ]
                    )
                } else {
                    Terminal.log("Project not found.")
                }
            }
        })
    }
}
