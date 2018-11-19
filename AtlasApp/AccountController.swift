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
    @IBOutlet var tokenField: NSTextField!
    @IBOutlet var s3AccessKeyField: NSTextField!
    @IBOutlet var s3SecretField: NSSecureTextField!
    @IBOutlet var errorMessage: NSTextField!
    @IBOutlet var welcomeMessage: NSTextField!
    
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
        tokenField.delegate = self
        s3AccessKeyField.delegate = self
        s3SecretField.delegate = self

        tokenField.isHidden = true
        
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
        
        let password = self.passwordField.stringValue.count > 0 ?
            self.passwordField.stringValue : nil
        
        var token = self.tokenField.stringValue.count > 0 ?
            self.tokenField.stringValue : nil
        
        if let credentials = credentials {
            if credentials.username != username || credentials.password != password {
                token = nil
            }
        }
        
        Timer.scheduledTimer(
            withTimeInterval: 0.1,
            repeats: false,
            block: { (timer) in
                self.mainController.initializeAtlas(
                    Credentials(
                        username,
                        email: email,
                        password: password,
                        token: token,
                        s3AccessKey: self.s3AccessKeyField.stringValue.count > 0 ?
                            self.s3AccessKeyField.stringValue : nil,
                        s3SecretAccessKey: self.s3SecretField.stringValue.count > 0 ?
                            self.s3SecretField.stringValue : nil
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
            passwordField.stringValue = credentials!.password ?? ""
        }

        if tokenField != nil {
            tokenField.stringValue = credentials!.token ?? ""
        }

        if s3AccessKeyField != nil {
            s3AccessKeyField.stringValue = credentials!.s3AccessKey ?? ""
        }
        
        if s3SecretField != nil {
            s3SecretField.stringValue = credentials!.s3SecretAccessKey ?? ""
        }

        if let authenticationError = credentials?.authenticationError {
            if welcomeMessage != nil {
                welcomeMessage.isHidden = true
            }
            
            if errorMessage != nil {
                errorMessage.isHidden = false
                errorMessage.stringValue = "Authentication Error\n\(authenticationError)"
            }
        }
    }
    
}


