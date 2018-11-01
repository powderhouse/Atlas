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
            Timer.scheduledTimer(
                withTimeInterval: 0,
                repeats: false,
                block: { (timer) in
                    self.performSegue(
                        withIdentifier: NSStoryboardSegue.Identifier(rawValue: "account-segue"),
                        sender: self
                    )
                    
            })
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
            DispatchQueue.global(qos: .background).async {
                _ = self.atlasCore.atlasCommit()
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "staged-file-ready-for-commit"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            let message = notification.userInfo?["message"] as? String
            
            if let projectName = notification.userInfo?["projectName"] as? String {
                DispatchQueue.global(qos: .background).async {
                    let result = self.atlasCore.commitChanges(message ?? "Commit (no message provided)")
                    DispatchQueue.main.async(execute: {
                        if result.success {
                            NotificationCenter.default.post(
                                name: NSNotification.Name(rawValue: "staged-file-commit-complete"),
                                object: nil,
                                userInfo: ["projectName": projectName]
                            )
                            Terminal.log("Files synced to S3.")
                        } else {
                            Terminal.log("Failed to commit staged files and sync with S3.")
                        }
                    })
                }
                
                var gitCommitComplete = false
                DispatchQueue.global(qos: .background).async {
                    while !gitCommitComplete {
                        if let status = self.atlasCore.status() {
                            if !status.contains(projectName) {
                                DispatchQueue.main.async(execute: {
                                    NotificationCenter.default.post(
                                        name: NSNotification.Name(rawValue: "staged-file-committed"),
                                        object: nil,
                                        userInfo: ["projectName": projectName]
                                    )
                                })
                                gitCommitComplete = true
                            }
                        }
                        sleep(1)
                    }
                }
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
                        DispatchQueue.global(qos: .background).async {
                            let result = self.atlasCore.purge([filePath])
                            if result.success {
                                DispatchQueue.main.async(execute: {
                                    Terminal.log("Successfully purged file from Atlas.")
                                    
                                    NotificationCenter.default.post(
                                        name: NSNotification.Name(rawValue: "staged-file-updated"),
                                        object: nil,
                                        userInfo: ["projectName": project!.name!]
                                    )
                                })
                            } else {
                                Terminal.log("File purge failed.")
                            }
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
        DispatchQueue.main.async(execute: {
            super.view.setNeedsDisplay(super.view.bounds)
            
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: "refresh"),
                object: nil
            )
        })
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
                        DispatchQueue.main.async(execute: {
                            NotificationCenter.default.post(
                                name: NSNotification.Name(rawValue: "project-added"),
                                object: nil,
                                userInfo: ["projectName": AtlasCore.defaultProjectName]
                            )
                        })
                    } else {
                        self.atlasCore.sync(completed: { Terminal.log("Sync Complete") })
                    }
                    
                    self.refresh()
                    Timer.scheduledTimer(
                        withTimeInterval: 1,
                        repeats: false,
                        block: { (timer) in
                            self.refresh()
                    })
                } else {
                    if result.messages.contains("Failed to authenticate with GitHub and no local repository provided.") || result.messages.contains("Unable to access these remotes: \(GitAnnex.remoteName)") ||
                        result.messages.contains("Unable to sync with S3. Please check credentials.") ||
                        result.messages.contains("Invalid AWS credentials") {
                        DispatchQueue.main.async(execute: {
                            self.performSegue(
                                withIdentifier: NSStoryboardSegue.Identifier(rawValue: "account-segue"),
                                sender: self
                            )
                        })
                    }
                }
            }
        }
    }
    
    func initAtlasCore() {
        let log: (_ message: String) -> Void = { (message) in
            Terminal.log(message)
        }
        
        if ProcessInfo.processInfo.environment["TESTING"] != nil {
            let tempDir = NSTemporaryDirectory()
            let directory = URL(fileURLWithPath: tempDir).appendingPathComponent("ATLASTEST")
            _ = FileSystem.deleteDirectory(directory)
            atlasCore = AtlasCore(directory, externalLog: log)
        } else {
            atlasCore = AtlasCore(externalLog: log)
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if atlasCore == nil {
            initAtlasCore()
        }
        
        if segue.identifier!.rawValue == "account-segue" {
            let dvc = segue.destinationController as! AccountController
            dvc.userDirectory = atlasCore.userDirectory
            dvc.credentials = atlasCore.getCredentials()
            dvc.mainController = self
        } else if segue.identifier!.rawValue == "panel-embed" {
            let dvc = segue.destinationController as! PanelController
            dvc.atlasCore = atlasCore
        }
    }
}

