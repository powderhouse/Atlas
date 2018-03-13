//
//  ViewController.swift
//  AtlasApp
//
//  Created by Jared Cosulich on 3/12/18.
//

import Cocoa
import AtlasCore

class ViewController: NSViewController {

    @IBOutlet weak var label: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let atlasCore = AtlasCore()
        _ = atlasCore.initGitAndGitHub(Credentials("atlastest", password: "1a2b3c4d"))
        label.stringValue = atlasCore.status() ?? "No Status"
        print(atlasCore.status() ?? "No Status")
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

