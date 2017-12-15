//
//  MainController.swift
//  atlas
//
//  Created by Jared Cosulich on 11/15/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Cocoa

class MainController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource, NSTextDelegate {

    @IBOutlet weak var projectListView: NSCollectionView!

    @IBOutlet weak var stagedFilesView: NSCollectionView!
    
    @IBOutlet weak var addProjectButton: NSButton!
    
    @IBOutlet weak var usernameLabel: NSTextField!
    
    @IBOutlet weak var currentProjectLabel: NSTextField!
    
    @IBOutlet var commitMessageField: NSTextView!
    
    @IBOutlet weak var commitButton: NSButton!
    
    @IBOutlet var terminalView: NSTextView!
    var terminal: Terminal!
    
    var git: Git?
    
    var projects: Projects?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        if ProcessInfo.processInfo.environment["TESTING"] != nil {
            Testing.setup()
        }
        
        terminal = Terminal(terminalView)
        
        Terminal.log("Welcome to Atlas!")
        
        configureCollectionView()
        
        FileSystem.createBaseDirectory()
        
        Terminal.log("Atlas Directory: \(FileSystem.baseDirectory().relativePath)")
        
        if let credentials = Git.getCredentials(FileSystem.baseDirectory()) {
            initGit(credentials)
            _ = projects?.create("General")
            updateProjects()
            selectProject("General")
        } else {
            performSegue(
                withIdentifier: NSStoryboardSegue.Identifier(rawValue: "account-modal"),
                sender: self
            )
        }
        
        initCommands()
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
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == projectListView {
            return projects?.list().count ?? 0
        }
        
        return projects?.active?.stagedFiles.count ?? 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {

        if collectionView == projectListView {
            let item = collectionView.makeItem(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ProjectViewItem"),
                for: indexPath
            )
            guard let projectViewItem = item as? ProjectViewItem else {
                return item
            }

            if let project = projects?.list()[indexPath.item] {
                NotificationCenter.default.addObserver(
                    forName: NSNotification.Name(rawValue: "project-staged-files"),
                    object: project,
                    queue: nil
                ) {
                    (notification) in
                    if let notificationProject = notification.object as? Project {
                        self.selectProject(notificationProject.name)
                        self.projects?.commitChanges()
                    }
                }

                projectViewItem.project = project
            }
            
            return projectViewItem
        }
        let item = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "StagedFileViewItem"),
            for: indexPath
        )
        guard let stagedFileViewItem = item as? StagedFileViewItem else {
            return item
        }
        
        let stagedFile = projects?.active?.stagedFiles[indexPath.item]
        stagedFileViewItem.label.stringValue = stagedFile ?? "Project"
        
        return stagedFileViewItem
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        if let selectedIndex = indexPaths.first?.item {
            if let project = projects?.list()[selectedIndex] {
                selectProject(project.name)
            }
        }
    }
    
    fileprivate func configureCollectionView() {
        projectListView.isSelectable = true
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 120.0, height: 120.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 10.0
        projectListView.collectionViewLayout = flowLayout

        view.wantsLayer = true
        
        projectListView.layer?.backgroundColor = NSColor.black.cgColor
    }
    
    func textDidChange(_ notification: Notification) {
        if let commitMessage = commitMessageField.textStorage?.string {
            commitButton.isEnabled = (commitMessage.count > 0)
        }
    }
    
    func initCommands() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "git-status"),
            object: terminal,
            queue: nil
        ) {
            (notification) in
            if let status = self.git?.status() {
                Terminal.log(status)
            }
        }
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
        
        Terminal.log("GitHub: \(git!.githubRepositoryLink!)")
        
        projects = Projects(git!.repositoryDirectory, git: git!)
        updateHeader()
    }
    
    func initGeneralRepository() {
        guard git != nil && projects != nil else {
            return
        }
        
        let generalProjectName = "General"
        
        _ = projects!.create(generalProjectName)
        
        selectProject(generalProjectName)
    }
    
    func updateProjects() {
        projectListView.reloadData()
    }
    
    func selectProject(_ projectName: String) {
        currentProjectLabel.stringValue = "Current Project: \(projectName)"
        currentProjectLabel.isHidden = false
        
        projects?.setActive(projectName)
        stagedFilesView.reloadData()
        
        Terminal.log("Active Project: \(projectName)")
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


