//
//  LogController.swift
//  AtlasApp
//
//  Created by Jared Cosulich on 3/15/18.
//

import Cocoa
import AtlasCore

class LogController: NSViewController {
    
    var atlasCore: AtlasCore!
    
    @IBOutlet weak var logView: NSCollectionView!
    var activityLog: ActivityLog!
    
    @IBOutlet var terminalView: NSTextView!
    var terminal: Terminal!
    
    var selectedProject: String? {
        didSet {
            activityLog.selectedProject = selectedProject
        }
    }
    
    override func viewDidLoad() {
        terminal = Terminal(terminalView, atlasCore: atlasCore)

        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        activityLog = ActivityLog(logView, atlasCore: atlasCore)
        
        initNotifications()
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
    
    func initNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "filter-project"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            if let projectName = notification.userInfo?["projectName"] as? String {
                if self.selectedProject == projectName {
                    self.selectedProject = nil
                } else {
                    self.selectedProject = projectName
                }
            }
        }
    }
    
}

