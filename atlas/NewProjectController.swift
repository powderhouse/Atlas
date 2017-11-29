//
//  NewProjectController.swift
//  atlas
//
//  Created by Jared Cosulich on 11/17/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Cocoa

class NewProjectController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var projectNameField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        projectNameField.delegate = self
        projectNameField.becomeFirstResponder()
    }
    
    @IBAction func createProject(_ sender: NSButton) {
        if let accountName = FileSystem.account() {
            let projectName = projectNameField.stringValue
            _ = FileSystem.createDirectory("\(accountName)/\(projectName)")
            if let mc = self.presenting as? MainController {
                mc.updateProjects()
                mc.selectProject(projectName)
            }
        }
        
        self.dismiss(nil)
    }
}
