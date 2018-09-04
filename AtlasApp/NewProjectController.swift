//
//  NewProjectController.swift
//  AtlasApp
//
//  Created by Jared Cosulich on 4/3/18.
//

import Cocoa
import AtlasCore

class NewProjectController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var projectNameField: NSTextField!
    
    var atlasCore: AtlasCore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        projectNameField.delegate = self
        projectNameField.becomeFirstResponder()
    }
    
    @IBAction func createProject(_ sender: NSButton) {
        let projectName = projectNameField.stringValue
        
        if let stagingController = self.presentingViewController as? StagingController {
            stagingController.addProject(projectName)
        }
        
        self.dismiss(nil)
    }
}
