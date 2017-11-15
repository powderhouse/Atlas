//
//  WelcomeController.swift
//  atlas
//
//  Created by Alec Resnick on 11/15/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Cocoa

class WelcomeController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var emailField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        emailField.delegate = self
        emailField.becomeFirstResponder()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func start(_ sender: NSButton) {
        print(emailField.stringValue)
    }
}

