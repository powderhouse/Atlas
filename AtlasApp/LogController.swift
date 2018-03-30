//
//  LogController.swift
//  AtlasApp
//
//  Created by Jared Cosulich on 3/15/18.
//

import Cocoa
import AtlasCore

class LogController: NSViewController {
    
    @IBOutlet var terminalView: NSTextView!
    var terminal: Terminal!
    
    override func viewDidLoad() {
        terminal = Terminal(terminalView)

        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func resize(_ sender: NSButton) {
        if let panels = self.parent as? NSSplitViewController {
            if let main = panels.parent {
                let newPosition = main.view.frame.width * 0.2
                panels.splitView.setPosition(newPosition, ofDividerAt: 0)
            }
        }
    }
    
}

