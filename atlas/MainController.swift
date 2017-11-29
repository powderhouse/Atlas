//
//  MainController.swift
//  atlas
//
//  Created by Jared Cosulich on 11/15/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Cocoa

class MainController: NSViewController {
    
    var email: String? {
        didSet {
            if email != nil {
                _ = FileSystem.createAccount(email!)
            }
            updateHeader()
        }
    }
    
    @IBOutlet weak var addProjectButton: NSButton!
    @IBOutlet weak var emailLabel: NSTextField!
    @IBOutlet weak var currentProjectLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        if ProcessInfo.processInfo.environment["TESTING"] != nil {
            Testing.setup()
        }
        
        email = FileSystem.account()
        
        if email == nil {
            performSegue(
                withIdentifier: NSStoryboardSegue.Identifier(rawValue: "account-modal"),
                sender: self
            )
        } else {
            updateHeader()
        }
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
//    func updateProjects() {
//        projects = FileSystem.projects
//    }
    
    func selectProject(_ projectName: String) {
        currentProjectLabel.stringValue = "Current Project: \(projectName)"
        currentProjectLabel.isHidden = false
    }
    
    func updateHeader() {
        if let definedEmail = email {
            emailLabel.stringValue = "Account: \(definedEmail)"
        } else {
            emailLabel.stringValue = "Account"
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier?.rawValue == "account-modal" {
            let dvc = segue.destinationController as! AccountController
            if email != nil {
                dvc.emailField.stringValue = email!
            }
            dvc.mainController = self
        }
    }
}


