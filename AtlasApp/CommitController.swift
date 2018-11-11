//
//  CommitController.swift
//  atlas
//
//  Created by Jared Cosulich on 1/20/18.
//  Copyright © 2018 Powderhouse Studios. All rights reserved.
//

import Cocoa
import AtlasCore

class CommitController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var commitButton: NSButton!
    
    @IBOutlet weak var commitMessage: NSTextField!
    
    @IBOutlet weak var files: NSTextField!
    
    var toCommit: [String] = [] {
        didSet {
            files.stringValue = ""
            for file in toCommit {
                files.stringValue.append("✅ \(file)\n")
            }
            files.sizeToFit()
        }
    }
    
    var project: Project?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        commitMessage.delegate = self
        commitMessage.becomeFirstResponder()
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        commitButton.isEnabled = commitMessage.stringValue.count > 0
    }
    
    @IBAction func commit(_ sender: NSButton) {
        guard project != nil else { return }
        self.dismiss(self)
        if project!.commitMessage(commitMessage.stringValue) {
            DispatchQueue.global(qos: .background).async {
                if self.project!.commitStaged().success {
                    DispatchQueue.main.async(execute: {
                        NotificationCenter.default.post(
                            name: NSNotification.Name(rawValue: "staged-file-ready-for-commit"),
                            object: nil,
                            userInfo: [
                                "projectName": self.project!.name!
                            ]
                        )
                        
                        Terminal.log("Files successfully committed.")
                    })
                } else {
                    Terminal.log("Failed to commit files.")
                }
            }
        } else {
            Terminal.log("Failed to set commit message.")
        }
    }
}
