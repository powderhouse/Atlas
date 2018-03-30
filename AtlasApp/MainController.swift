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
    
    override func viewDidLoad() {
        if atlasCore == nil {
            initAtlasCore()
        }
        
        if ProcessInfo.processInfo.environment["TESTING"] != nil {
            reset()
        }

        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        initNotifications()
        
        if let credentials = atlasCore.getCredentials() {
            initializeAtlas(credentials)
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
            forName: NSNotification.Name(rawValue: "staged-file-added"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            self.atlasCore.atlasCommit()
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "staged-file-committed"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            self.atlasCore.atlasCommit(notification.userInfo?["message"] as? String)
        }
    }

    func initializeAtlas(_ credentials: Credentials) {
        if atlasCore.initGitAndGitHub(credentials) {
            Terminal.log("Logged in to Atlas.")
            Terminal.log("Account: \(credentials.username)")
            Terminal.log("Local Repository: \(atlasCore.atlasDirectory?.path ?? "N/A")")
            Terminal.log("GitHub Repository: \(atlasCore.gitHubRepository() ?? "N/A")")
            
            if atlasCore.projects().count == 0 {
                _ = atlasCore.initProject("General")
                _ = atlasCore.atlasCommit()
            }
        } else {
            Terminal.log("ERROR: Failed to initialize github")
        }
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
            if let currentCredentials = atlasCore.getCredentials() {
                dvc.usernameField.stringValue = currentCredentials.username
            }
            dvc.mainController = self
        } else if segue.identifier?.rawValue == "panel-embed" {
            let dvc = segue.destinationController as! PanelController
            dvc.atlasCore = atlasCore
        }
    }
}

