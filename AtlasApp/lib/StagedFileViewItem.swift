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

    var projectViewItem: ProjectViewItem!
    
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var selectCheck: NSButton!
    @IBOutlet weak var removeButton: NSButton!
    
    override var isSelected: Bool {
        get {
            return selectCheck.state == NSControl.StateValue.on
        }
        set(newValue) {
            selectCheck.state = (newValue ? NSControl.StateValue.on : NSControl.StateValue.off)
            projectViewItem.checkCommitButton()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
    
    @IBAction func select(_ sender: NSButton) {
        let newState = isSelected ? "staged" : "unstaged"
        
        if let project = projectViewItem.project {
            let result = project.changeState([label.stringValue], to: newState)
            Terminal.log(result.allMessages)
            if result.success {
                NotificationCenter.default.post(
                    name: NSNotification.Name(rawValue: "staged-file-updated"),
                    object: nil,
                    userInfo: [
                        "projectName": project.name!
                    ]
                )
                
                Terminal.log("Successfully \(newState) file.")
            } else {
                Terminal.log("There was an error changing the state of the file.")
            }
        } else {
            Terminal.log("Project not found.")
        }
        
        projectViewItem.checkCommitButton()
    }
    
    @IBAction func remove(_ sender: NSButton) {
        let a = NSAlert()
        a.messageText = "Remove this file?"
        a.informativeText = "Are you sure you would like to remove this file?"
        a.addButton(withTitle: "Remove File")
        a.addButton(withTitle: "Cancel")
        
        a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                if let project = self.projectViewItem.project {
                    NotificationCenter.default.post(
                        name: NSNotification.Name(rawValue: "remove-staged-file"),
                        object: nil,
                        userInfo: [
                            "projectName": project.name!,
                            "state": self.isSelected ? "staged" : "unstaged",
                            "fileName": self.label.stringValue
                        ]
                    )
                } else {
                    Terminal.log("Project not found.")
                }
            }
        })
    }
}
