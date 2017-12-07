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
    
    @IBOutlet weak var usernameLabel: NSTextField!
    
    @IBOutlet weak var currentProjectLabel: NSTextField!
    
    @IBOutlet weak var githubRepositoryLabel: NSTextField!
    
    @IBOutlet weak var projectsList: NSTextField!
    
    var git: Git?
    
    var projects: Projects?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        if ProcessInfo.processInfo.environment["TESTING"] != nil {
            Testing.setup()
        }
        
        FileSystem.createBaseDirectory()
        
        if let credentials = Git.getCredentials(FileSystem.baseDirectory()) {
            initGit(credentials)
            initGeneralRepository()
            updateProjects()
        } else {
            performSegue(
                withIdentifier: NSStoryboardSegue.Identifier(rawValue: "account-modal"),
                sender: self
            )
        }
    }
    
    override func viewDidDisappear() {
        if ProcessInfo.processInfo.environment["TESTING"] != nil {
            Testing.setup()
        }
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
        return projects?.list()[index] ?? ""
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return projects?.list().count ?? 0
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
        selectProject(projects?.list()[projectListView.selectedRow] ?? "")
    }
    
    func initGit(_ credentials: Credentials) {
        let atlasRepository = FileSystem.baseDirectory().appendingPathComponent("Atlas", isDirectory: true)
        
        if !FileSystem.fileExists(atlasRepository) {
            FileSystem.createDirectory(atlasRepository)
        }

        git = Git(atlasRepository, credentials: credentials)

        guard git != nil else {
            return
        }

        let readme = atlasRepository.appendingPathComponent("readme.md", isDirectory: false)
        if !FileSystem.fileExists(readme, isDirectory: false) {
            do {
                try "Welcome to Atlas".write(to: readme, atomically: true, encoding: .utf8)
            } catch {}

            _ = git!.runInit()
            _ = git!.initGitHub()
        }
        
        displayRepositoryLink()
        
        projects = Projects(git!.repositoryDirectory)
        updateHeader()
    }
    
    func displayRepositoryLink() {
        if let repositoryLink = git!.githubRepositoryLink {
            if repositoryLink.count > 0 {
                githubRepositoryLabel.stringValue = "GitHub Repository: \(repositoryLink)"
                githubRepositoryLabel.isHidden = false
                return
            }
        }
        githubRepositoryLabel.isHidden = true
    }
    
    func initGeneralRepository() {
        guard git != nil && projects != nil else {
            return
        }
        
        let generalProjectName = "General"
        
        let generalFolder = projects!.create(generalProjectName)
        
        let readme = generalFolder!.appendingPathComponent("readme.md", isDirectory: false)
        if !FileSystem.fileExists(readme) {
            do {
                try "This is your General Folder".write(to: readme, atomically: true, encoding: .utf8)
            } catch {}
            
            _ = git!.add()
            _ = git!.commit()
            _ = git!.pushToGitHub()
        }
        
        selectProject(generalProjectName)
    }
    
    func updateProjects() {
        projectListView.reloadData()
    }
    
    func selectProject(_ projectName: String) {
        currentProjectLabel.stringValue = "Current Project: \(projectName)"
        currentProjectLabel.isHidden = false
    }
    
    func updateHeader() {
        if let username = git?.credentials.username {
            usernameLabel.stringValue = "Account: \(username)"
        } else {
            usernameLabel.stringValue = "Account"
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier?.rawValue == "account-modal" {
            let dvc = segue.destinationController as! AccountController
            if let currentGit = git {
                dvc.usernameField.stringValue = currentGit.credentials.username
            }
            dvc.mainController = self
        } else if segue.identifier?.rawValue == "new-project-modal" {
            let dvc = segue.destinationController as! NewProjectController
            dvc.projects = projects
        }
    }
}


