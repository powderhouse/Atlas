//
//  AccountController.swift
//  atlas
//
//  Created by Alec Resnick on 11/15/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Cocoa

class AccountController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var emailField: NSTextField!
    
    @IBOutlet weak var passwordField: NSSecureTextField!
    
    weak var mainController: MainController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        emailField.delegate = self
        passwordField.delegate = self

        emailField.becomeFirstResponder()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func save(_ sender: NSButtonCell) {
        mainController.initGit(
            Credentials(
                username: emailField.stringValue,
                password: passwordField.stringValue,
                token: nil
            )
        )
        self.dismiss(nil)
    }
    
}

