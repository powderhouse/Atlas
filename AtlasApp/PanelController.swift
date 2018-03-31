//
//  PanelController.swift
//  AtlasApp
//
//  Created by Jared Cosulich on 3/29/18.
//

import Cocoa
import AtlasCore

class PanelController: NSSplitViewController {
    
    @IBOutlet weak var stagingArea: NSSplitViewItem!
    
    @IBOutlet weak var logArea: NSSplitViewItem!
    
    var atlasCore: AtlasCore!
    
    override func viewDidLoad() {
        if let stagingController = stagingArea.viewController as? StagingController {
            stagingController.atlasCore = atlasCore
        }

        if let logController = logArea.viewController as? LogController {
            logController.atlasCore = atlasCore
        }

        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
