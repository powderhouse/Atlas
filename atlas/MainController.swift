//
//  MainController.swift
//  atlas
//
//  Created by Jared Cosulich on 11/15/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Cocoa

class MainController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource {

    @IBOutlet weak var projectListScrollView: NSScrollView!
    
    @IBOutlet weak var projectListView: NSCollectionView!
    
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
        
        configureCollectionView()
        
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
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return projects?.list().count ?? 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ProjectViewItem"),
            for: indexPath
        )
        guard let projectViewItem = item as? ProjectViewItem else {
            return item
        }
        
        projectViewItem.label.stringValue = (projects?.list()[indexPath.item])!
        return projectViewItem
    }
    
    fileprivate func configureCollectionView() {
//        projectListView.register(
//            ProjectViewItem.self,
//            forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ProjectViewItem")
//        )
        
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 120.0, height: 120.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 10.0
        projectListView.collectionViewLayout = flowLayout

        view.wantsLayer = true
        
        projectListView.layer?.backgroundColor = NSColor.black.cgColor
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
        
        projects = Projects(git!.repositoryDirectory, git: git!)
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
        
        _ = projects!.create(generalProjectName)
        
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


