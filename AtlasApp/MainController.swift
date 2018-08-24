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
        _ = atlasCore.deleteBaseDirectory()
        atlasCore.deleteGitHubRepository()
    }
    
    func initNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "staged-file-updated"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            Terminal.log(self.atlasCore.atlasCommit().allMessages)
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "staged-file-ready-for-commit"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            let message = notification.userInfo?["message"] as? String
            let result = self.atlasCore.commitChanges(message ?? "Commit (no message provided)")
            Terminal.log(result.allMessages)
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
                        let result = self.atlasCore.purge([filePath])
                        Terminal.log(result.allMessages)
                        if result.success {
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
        if let core = atlasCore {
            DispatchQueue.global(qos: .background).async {
                let result = core.initGitAndGitHub(credentials)
                if result.success {
                    self.refresh()
                    Terminal.log("Logged in to Atlas.")
                    Terminal.log("Account: \(credentials.username)")
                    Terminal.log("Local Repository: \(core.appDirectory?.path ?? "N/A")")
                    Terminal.log("GitHub Repository: \(core.gitHubRepository() ?? "N/A")")
                    Terminal.log("S3 Repository: \(core.s3Repository() ?? "N/A")")
                    
                    let searchResult = core.initSearch()
                    if !searchResult.success {
                        Terminal.log("Failed to initialize search.")
                        Terminal.log(searchResult.allMessages)
                    }
                    
                    if core.projects().count == 0 {
                        NotificationCenter.default.post(
                            name: NSNotification.Name(rawValue: "project-added"),
                            object: nil,
                            userInfo: ["projectName": AtlasCore.defaultProjectName]
                        )
                    }
                } else {
                    Terminal.log("ERROR: Failed to initialize github")
                }
                
                self.refresh()
                Timer.scheduledTimer(
                    withTimeInterval: 1,
                    repeats: false,
                    block: { (timer) in
                        self.refresh()
                })
            }
        }
    }
    
    func initAtlasCore() {
        let log: (_ message: String) -> Void = { (message) in
            Terminal.log(message)
        }
        
        if let directoryPath = ProcessInfo.processInfo.environment["atlasDirectory"] {
            let directory = URL(fileURLWithPath: directoryPath)
            atlasCore = AtlasCore(directory, log: log)
        } else {
            atlasCore = AtlasCore(log: log)
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if atlasCore == nil {
            initAtlasCore()
        }
        
        if segue.identifier?.rawValue == "account-segue" {
            let dvc = segue.destinationController as! AccountController
            dvc.userDirectory = atlasCore.userDirectory
            dvc.credentials = atlasCore.getCredentials()
            dvc.mainController = self
        } else if segue.identifier?.rawValue == "panel-embed" {
            let dvc = segue.destinationController as! PanelController
            dvc.atlasCore = atlasCore
        }
    }
}

