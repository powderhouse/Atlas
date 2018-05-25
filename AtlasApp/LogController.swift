//
//  LogController.swift
//  AtlasApp
//
//  Created by Jared Cosulich on 3/15/18.
//

import Cocoa
import AtlasCore

class LogController: NSViewController, NSTextFieldDelegate {
    
    var atlasCore: AtlasCore!
    
    @IBOutlet weak var logView: NSCollectionView!
    var activityLog: ActivityLog!
    
    @IBOutlet var searchText: NSTextField!
    @IBOutlet var searchButton: NSButton!
    
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
        
        searchText.delegate = self
        
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
    
    @IBAction func performSearch(_ sender: NSButton) {
        var slugs: [String]?=nil
        if searchText.stringValue.count > 0 {
            let searchResults = atlasCore.search.search(searchText.stringValue)
            
            if searchResults.count > 0 {
                slugs = []
                for result in searchResults {
                    if let slug = result.deletingLastPathComponent?.lastPathComponent {
                        if !slugs!.contains(slug) {
                            slugs!.append(slug)
                        }
                    }
                }
            }
        }
        activityLog.commitSlugFilter = slugs
        activityLog.refresh()
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        if ((obj.userInfo?["NSTextMovement"] as? Int) ?? 0) == Int(NSReturnTextMovement) {
            performSearch(searchButton)
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

