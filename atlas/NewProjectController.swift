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
    
    var projects: Projects!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        projectNameField.delegate = self
        projectNameField.becomeFirstResponder()
    }
    
    @IBAction func createProject(_ sender: NSButton) {
        let projectName = projectNameField.stringValue
        _ = projects.create(projectName)
        if let mc = self.presenting as? MainController {
            mc.updateProjects()
            mc.selectProject(projectName)
        }
        
        self.dismiss(nil)
    }
}
