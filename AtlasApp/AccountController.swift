//
//  AccountController.swift
//  AtlasApp
//
//  Created by Jared Cosulich on 3/14/18.
//

import Cocoa
import AtlasCore

class AccountController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var usernameField: NSTextField!
    var username: String?  {
        didSet {
            if usernameField != nil {
                usernameField.stringValue = username!
            }
        }
    }

    @IBOutlet weak var passwordField: NSSecureTextField!
    var password: String?  {
        didSet {
            if passwordField != nil {
                passwordField.stringValue = password!
            }
        }
    }

    weak var mainController: MainController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        if usernameField != nil {
            if username != nil {
                usernameField.stringValue = username!
            } else {
                usernameField.becomeFirstResponder()
            }
        }

        if passwordField != nil && password != nil {
            passwordField.stringValue = password!
        }
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func save(_ sender: NSButtonCell) {
        mainController.initializeAtlas(
            Credentials(
                usernameField.stringValue,
                password: passwordField.stringValue,
                token: nil
            )
        )
        
        self.dismiss(nil)
    }
    
}


