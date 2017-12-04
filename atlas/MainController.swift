//
//  MainController.swift
//  atlas
//
//  Created by Jared Cosulich on 11/15/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Cocoa

class MainController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    @IBOutlet weak var projectListScrollView: NSScrollView!
    
    @IBOutlet weak var projectListView: NSOutlineView!
    
    @IBOutlet weak var addProjectButton: NSButton!
    
    @IBOutlet weak var emailLabel: NSTextField!
    
    @IBOutlet weak var currentProjectLabel: NSTextField!
    
    @IBOutlet weak var projectsList: NSTextField!
    
    var projects: [String] = []
    
    var git: Git?  {
        didSet {
            updateHeader()
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        if ProcessInfo.processInfo.environment["TESTING"] != nil {
            Testing.setup()
        }
        
        if let credentials = Git.getCredentials(FileSystem.baseDirectory()) {
            initGit(credentials)
            updateHeader()
        } else {
            performSegue(
                withIdentifier: NSStoryboardSegue.Identifier(rawValue: "account-modal"),
                sender: self
            )
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
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return projects[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: NSTableView,
                   objectValueFor tableColumn: NSTableColumn?,
                   row: Int) -> Any? {
        return "XXX"
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor viewForTableColumn: NSTableColumn?, item: Any) -> NSView? {
        let projectName = item as! String
        let identifier = NSUserInterfaceItemIdentifier(rawValue: "ProjectCell")
        let view = outlineView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView
        if let textField = view?.textField {
            textField.stringValue = projectName
            textField.sizeToFit()
        }
        
        return view
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return true
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification){
        selectProject(projects[projectListView.selectedRow])
    }
    
    func initGit(_ credentials: Credentials) {
        let atlasFolder = FileSystem.baseDirectory().appendingPathComponent("Atlas", isDirectory: true)
        git = Git(atlasFolder, credentials: credentials)
    }
    
    
    func updateProjects() {
        projects = FileSystem.projects()
        projectListView.reloadData()
    }
    
    func selectProject(_ projectName: String) {
        currentProjectLabel.stringValue = "Current Project: \(projectName)"
        currentProjectLabel.isHidden = false
    }
    
    func updateHeader() {
        print("UPDATE: \(git) -> \(git?.credentials)")
        if let username = git?.credentials.username {
            emailLabel.stringValue = "Account: \(username)"
        } else {
            emailLabel.stringValue = "Account"
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier?.rawValue == "account-modal" {
            let dvc = segue.destinationController as! AccountController
            if let currentGit = git {
                dvc.emailField.stringValue = currentGit.credentials.username
            }
            dvc.mainController = self
        }
    }
}


