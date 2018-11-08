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
    @IBOutlet var noSearch: NSTextField!
    
    @IBOutlet weak var terminalGroup: NSView!
    @IBOutlet var terminalView: NSTextView!
    @IBOutlet weak var terminalInput: NSTextField!
    var terminal: Terminal!
    @IBOutlet weak var showTerminalButton: NSButton!
    
    var selectedProject: String? {
        didSet {
            activityLog.selectedProject = selectedProject
        }
    }
    
    override func viewDidLoad() {
        terminal = Terminal(input: terminalInput, output: terminalView, atlasCore: atlasCore)

        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        activityLog = ActivityLog(logView, atlasCore: atlasCore)
        
        searchText.delegate = self
        
        showTerminalButton.isHidden = true
        
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
    
    @IBAction func hideTerminal(_ sender: NSButton) {
        terminal.deactivate()
        terminalGroup.isHidden = true
        showTerminalButton.isHidden = false
    }
    
    @IBAction func showTerminal(_ sender: NSButtonCell) {
        terminalGroup.isHidden = false
        showTerminalButton.isHidden = true
        Timer.scheduledTimer(
            withTimeInterval: 0.1,
            repeats: false,
            block: { (timer) in
                self.terminal.activate()
            }
        )
    }
    
    func performSearch() {
        let searchString = searchText.stringValue
        var searchResults: [NSURL]? = nil
        if searchString.count > 0 {
            searchResults = atlasCore.search.search(searchString)
            activityLog.searchResults = searchResults
        } else {
            activityLog.searchResults = nil
        }

        var terms: [String] = []
        let unquotedSections = searchString.components(separatedBy: "\"")
        for (index, section) in unquotedSections.enumerated() {
            if index % 2 == 1 && index + 1 < unquotedSections.count {
                terms.append(section)
            } else if index % 2 == 1 {
                let newSection = "\"" + section
                terms += newSection.components(separatedBy: " ")
            } else {
                terms += section.components(separatedBy: " ")
            }
        }
        
        activityLog.searchTerms = terms
        activityLog.refresh()
        
        noSearch.isHidden = (searchResults == nil || searchResults!.count > 0)
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        performSearch()
    }
    
    @IBAction func clickSearch(_ sender: NSClickGestureRecognizer) {
        searchText.selectText(searchText)
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

