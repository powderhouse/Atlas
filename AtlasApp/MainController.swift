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
        
        if ProcessInfo.processInfo.environment["TESTING"] != nil {
            if let testingDirectoryPath = ProcessInfo.processInfo.environment["atlasDirectory"] {
                let testingDirectory = URL(fileURLWithPath: testingDirectoryPath)
                atlasCore = AtlasCore(testingDirectory)
            }
        } else {
            atlasCore = AtlasCore()
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
            atlasCore.deleteBaseDirectory()
            atlasCore.deleteGitHubRepository()
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func initializeAtlas(_ credentials: Credentials) {
        if atlasCore.initGitAndGitHub(credentials) {
            print("Successfully initialized github")
        } else {
            print("ERROR: Failed to initialize github")
        }
    }
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier?.rawValue == "account-segue" {
            let dvc = segue.destinationController as! AccountController
            if let currentCredentials = atlasCore.getCredentials() {
                dvc.usernameField.stringValue = currentCredentials.username
            }
            dvc.mainController = self
        }
    }
}

