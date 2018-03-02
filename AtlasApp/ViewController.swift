//
//  ViewController.swift
//  AtlasApp
//
//  Created by Jared Cosulich on 2/12/18.
//

import Cocoa
import AtlasCore

class ViewController: NSViewController {

    let atlasCore = AtlasCore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("ATLAS DIRECTORY: \(atlasCore.baseDirectory)")
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

