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
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        if let directoryPath = ProcessInfo.processInfo.environment["atlasDirectory"] {
            let directory = URL(fileURLWithPath: directoryPath)
            atlasCore = AtlasCore(directory)
        } else {
            atlasCore = AtlasCore()
        }

        if ProcessInfo.processInfo.environment["TESTING"] != nil {
            reset()
        }
        
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

    func initializeAtlas(_ credentials: Credentials) {
        if atlasCore.initGitAndGitHub(credentials) {
            Terminal.log("Logged in to Atlas.")
            Terminal.log("Account: \(credentials.username)")
            Terminal.log("Local Repository: \(atlasCore.atlasDirectory?.path ?? "N/A")")
            Terminal.log("GitHub Repository: \(atlasCore.gitHubRepository() ?? "N/A")")
        } else {
            Terminal.log("ERROR: Failed to initialize github")
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
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

