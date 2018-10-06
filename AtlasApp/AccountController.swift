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
    @IBOutlet var emailField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet var s3AccessKeyField: NSTextField!
    @IBOutlet var s3SecretField: NSSecureTextField!
    
    var userDirectory: URL!

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
        emailField.delegate = self
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
        let username = self.usernameField.stringValue
        let email = self.emailField.stringValue
        
        guard username.count > 0 && email.count > 0 else {
            return
        }
        
        Terminal.log("Initializing Atlas")
        
        Timer.scheduledTimer(
            withTimeInterval: 0.1,
            repeats: false,
            block: { (timer) in
                self.mainController.initializeAtlas(
                    Credentials(
                        username,
                        email: email,
                        token: self.passwordField.stringValue.count > 0 ?
                            self.passwordField.stringValue : nil,
                        //token: self.credentials?.token,
                        s3AccessKey: self.s3AccessKeyField.stringValue.count > 0 ? self.s3AccessKeyField.stringValue : nil,
                        s3SecretAccessKey: self.s3SecretField.stringValue.count > 0 ? self.s3SecretField.stringValue : nil
                    )
                )
        })
        
        self.dismiss(nil)
    }
    
    func loadCredentials() {
        guard credentials != nil else { return }
        
        if usernameField != nil {
            usernameField.stringValue = credentials!.username
        }

        if emailField != nil {
            emailField.stringValue = credentials!.email
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


