//
//  ViewController.swift
//  AtlasApp
//
//  Created by Jared Cosulich on 3/12/18.
//

import Cocoa
import AtlasCore

class MainController: NSViewController {

    var atlasCore: AtlasCore!
    
    var selectedProject: String?
    
    override func viewDidLoad() {
        
        if atlasCore == nil {
            initAtlasCore()
        }
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        initNotifications()
        
        let credentials = atlasCore.getCredentials()
        
        if credentials != nil && credentials!.complete() {
            initializeAtlas(credentials!)
        } else {
            performSegue(
                withIdentifier: NSStoryboardSegue.Identifier(rawValue: "account-segue"),
                sender: self
            )
        }
    }
    
    override func viewDidDisappear() {
        if ProcessInfo.processInfo.environment["TESTING"] != nil {
            reset()
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func reset() {
        atlasCore.deleteBaseDirectory()
        atlasCore.deleteGitHubRepository()
    }
    
    func initNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "staged-file-updated"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            if !self.atlasCore.atlasCommit() {
                Terminal.log("There was an issue commiting. Trying again in a moment.")
                
                Timer.scheduledTimer(
                    withTimeInterval: 2,
                    repeats: false,
                    block: { (timer) in
                        NotificationCenter.default.post(
                            name: NSNotification.Name(rawValue: "staged-file-updated"),
                            object: nil
                        )
                })
                
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "staged-file-ready-for-commit"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            self.atlasCore.commitChanges(notification.userInfo?["message"] as? String)
            if let projectName = notification.userInfo?["projectName"] as? String {
                NotificationCenter.default.post(
                    name: NSNotification.Name(rawValue: "staged-file-committed"),
                    object: nil,
                    userInfo: ["projectName": projectName]
                )
            }
        }

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "remove-staged-file"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            if let projectName = notification.userInfo?["projectName"] as? String {
                let project = self.atlasCore.project(projectName)
                if let state = notification.userInfo?["state"] as? String {
                    if let fileName = notification.userInfo?["fileName"] as? String {
                        let filePath = "\(projectName)/\(state)/\(fileName)"
                        if self.atlasCore.purge([filePath]) {
                            Terminal.log("Successfully purged file from Atlas.")
                            
                            NotificationCenter.default.post(
                                name: NSNotification.Name(rawValue: "staged-file-updated"),
                                object: nil,
                                userInfo: ["projectName": project!.name!]
                            )
                        } else {
                            Terminal.log("File purge failed.")
                        }
                    } else {
                        Terminal.log("No filename specified.")
                    }
                } else {
                    Terminal.log("No file state specified.")
                }
            } else {
                Terminal.log("Project name not specified.")
            }
        }
    }
    
    func refresh() {
        super.view.setNeedsDisplay(super.view.bounds)
        
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: "refresh"),
            object: nil
        )
    }

    func initializeAtlas(_ credentials: Credentials) {
        if atlasCore.initGitAndGitHub(credentials) {
            refresh()
            Terminal.log("Logged in to Atlas.")
            Terminal.log("Account: \(credentials.username)")
            Terminal.log("Local Repository: \(atlasCore.appDirectory?.path ?? "N/A")")
            Terminal.log("GitHub Repository: \(atlasCore.gitHubRepository() ?? "N/A")")
            Terminal.log("S3 Repository: \(atlasCore.s3Repository() ?? "N/A")")

            if !atlasCore.initSearch() {
                Terminal.log("Failed to initialize search.")
            }
            
            if atlasCore.projects().count == 0 {
                NotificationCenter.default.post(
                    name: NSNotification.Name(rawValue: "project-added"),
                    object: nil,
                    userInfo: ["projectName": AtlasCore.defaultProjectName]
                )
            }
        } else {
            Terminal.log("ERROR: Failed to initialize github")
        }
        
        refresh()
        Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: false,
            block: { (timer) in
                self.refresh()
        })
    }
    
    func initAtlasCore() {
        if let directoryPath = ProcessInfo.processInfo.environment["atlasDirectory"] {
            let directory = URL(fileURLWithPath: directoryPath)
            atlasCore = AtlasCore(directory)
        } else {
            atlasCore = AtlasCore()
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if atlasCore == nil {
            initAtlasCore()
        }
        
        if segue.identifier?.rawValue == "account-segue" {
            let dvc = segue.destinationController as! AccountController
            dvc.credentials = atlasCore.getCredentials()
            dvc.mainController = self
        } else if segue.identifier?.rawValue == "panel-embed" {
            let dvc = segue.destinationController as! PanelController
            dvc.atlasCore = atlasCore
        }
    }
}

