//
//  MainController.swift
//  atlas
//
//  Created by Jared Cosulich on 11/15/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Cocoa

class MainController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    @IBOutlet weak var projectListView: NSScrollView!
    
    var email: String? {
        didSet {
            if email != nil {
                _ = FileSystem.createAccount(email!)
            }
            updateHeader()
        }
    }
    
    @IBOutlet weak var addProjectButton: NSButton!
    
    @IBOutlet weak var emailLabel: NSTextField!
    
    @IBOutlet weak var currentProjectLabel: NSTextField!
    
    @IBOutlet weak var projectsList: NSTextField!
    
    var projects: [String] = []
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        if ProcessInfo.processInfo.environment["TESTING"] != nil {
            Testing.setup()
        }

        email = FileSystem.account()
        
        if email == nil {
            performSegue(
                withIdentifier: NSStoryboardSegue.Identifier(rawValue: "account-modal"),
                sender: self
            )
        } else {
            updateHeader()
        }
        
        updateProjects()
        
        currentProjectLabel.isHidden = true
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView,
                     shouldExpandItem item: Any) -> Bool {
        print(-1)
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        print(0)
        return "ANY OBJECT" as AnyObject
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        print(1)
        return 2
    }
    
    
    func outlineView(_ outlineView: NSOutlineView, viewFor viewForTableColumn: NSTableColumn?, item: Any) -> NSView? {
        print(2)

        let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"), owner: self) as! NSTableCellView
        if let textField = view.textField {
            textField.stringValue = "test"
        }
        return view
        
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        print(3)
        return true
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification){
        print(4)
        print(notification)
    }
    
    
    func updateProjects() {
        return
//        projects = FileSystem.projects()
//        if projects.count == 0 {
//            projectsList.isHidden = true
//            return
//        }
//        
//        projectsList.isHidden = false
//        var projectsListText = "Projects:"
//        
//        for projectName in projects {
//            projectsListText.append("\n\n")
//            projectsListText.append(projectName)
//        }
//        
//        projectsList.stringValue = projectsListText
    }
    
    func selectProject(_ projectName: String) {
        currentProjectLabel.stringValue = "Current Project: \(projectName)"
        currentProjectLabel.isHidden = false
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


