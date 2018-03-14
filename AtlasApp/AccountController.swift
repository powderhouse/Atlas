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
    
    @IBOutlet weak var passwordField: NSSecureTextField!
    
    weak var mainController: MainController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        usernameField.becomeFirstResponder()
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


