//
//  NewTextController.swift
//  atlas
//
//  Created by Jared Cosulich on 12/21/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Cocoa

class NewTextController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var textField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        textField.delegate = self
        textField.becomeFirstResponder()
    }
    
    @IBAction func createTextFile(_ sender: NSButton) {
        print("TEXT: \(textField.stringValue)")
        self.dismiss(nil)
    }
}

