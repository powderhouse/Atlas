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
    @IBOutlet var s3AccessKeyField: NSTextField!
    @IBOutlet var s3SecretField: NSSecureTextField!

    var credentials: Credentials? {
        didSet {
            loadCredentials()
        }
    }

    weak var mainController: MainController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        usernameField.delegate = self
        passwordField.delegate = self
        s3AccessKeyField.delegate = self
        s3SecretField.delegate = self

        loadCredentials()
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
                token: credentials?.token,
                s3AccessKey: s3AccessKeyField.stringValue,
                s3SecretAccessKey: s3SecretField.stringValue
            )
        )
        
        self.dismiss(nil)
    }
    
    func loadCredentials() {
        guard credentials != nil else { return }
        
        if usernameField != nil {
            usernameField.stringValue = credentials!.username
        }
        
        if passwordField != nil {
            if credentials!.token != nil {
                passwordField.placeholderString = "GitHub Password Already Set"
                passwordField.isEnabled = false
            } else {
                passwordField.stringValue = credentials!.password ?? ""
            }
        }
        
        if s3AccessKeyField != nil {
            s3AccessKeyField.stringValue = credentials!.s3AccessKey ?? ""
        }
        
        if s3SecretField != nil {
            s3SecretField.stringValue = credentials!.s3SecretAccessKey ?? ""
        }
    }
    
}


