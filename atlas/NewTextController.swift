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
        let text = textField.stringValue
        
        var title = ""
        if text.starts(with: "http") {
            let mercuryArguments = [
                "-H",
                "x-api-key: boI6U8y0OOzHVs7lftXWiCPqYw3eeoJYCUd97i7I",
                "https://mercury.postlight.com/parser?url=\(textField.stringValue)"
            ]
            
            let response = Glue.runProcess("curl", arguments: mercuryArguments)
            let data = response.data(using: .utf8)!
            let websiteJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            if let websiteTitle = websiteJson??["title"] as? String {
                if websiteTitle.count >= 20 {
                    let endIndex = websiteTitle.index(websiteTitle.startIndex, offsetBy: 20)
                    title = String(websiteTitle[...endIndex]) + "..."
                } else {
                    title = websiteTitle
                }
            }
        } else {
            if text.count >= 20 {
                let endIndex = text.index(text.startIndex, offsetBy: 20)
                title = String(text[...endIndex]) + "..."
            } else {
                title = text
            }
        }
        
        if let mc = self.presenting as? MainController {
            if let project = mc.projects?.active {
                let url = project.staging.appendingPathComponent(title)
                do {
                    try text.write(to: url, atomically: true, encoding: .utf8)
                    project.stageFile(url)
                } catch {
                    Terminal.log("Error saving file: \(error)")
                }
            }
        }
        
        self.dismiss(nil)
    }
}

