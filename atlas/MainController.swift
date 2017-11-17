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
            updateHeader()
        }
    }
    
    @IBOutlet weak var emailLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if email == nil {
            performSegue(
                withIdentifier: NSStoryboardSegue.Identifier(rawValue: "account-modal"),
                sender: self
            )
        } else {
            updateHeader()
        }
        
        print(FileSystem.userDesktopDirectory())
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
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


