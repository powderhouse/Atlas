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


}

