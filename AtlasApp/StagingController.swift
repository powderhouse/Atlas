//
//  StagingController.swift
//  AtlasApp
//
//  Created by Jared Cosulich on 3/15/18.
//

import Cocoa
import AtlasCore

class StagingController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource {
    
    var atlasCore: AtlasCore!
    
    @IBOutlet weak var projectListView: NSCollectionView!
    
    var filterByProject: String?
    
    @IBOutlet weak var syncButton: NSButton!
    @IBOutlet weak var status: NSTextField!
    var statusTimer: Timer? = nil
    var syncProcesses: [String: Bool] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureProjectListView()
        initObservers()
        
        self.showStatus()
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func sync(_ sender: NSButton) {
        let completed = {
            Terminal.log("Sync Complete")
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: "refresh"),
                object: nil
            )
        }
        
        DispatchQueue.global(qos: .background).async {
            self.atlasCore.sync(completed: completed)
        }
        syncing()
    }
    
    @IBAction func resize(_ sender: NSButton) {
        if let panels = self.parent as? NSSplitViewController {
            if let main = panels.parent {
                let newPosition = main.view.frame.width * 0.8
                panels.splitView.setPosition(newPosition, ofDividerAt: 0)
            }
        }
    }
    
    func addProject(_ projectName: String) {
        DispatchQueue.global(qos: .background).async {
            if self.atlasCore.initProject(projectName) {
                DispatchQueue.main.async(execute: {
                    self.projectListView.reloadData()
                    Terminal.log("Added project: \(projectName)")
                })
                
                _ = self.atlasCore.atlasCommit()
            }
        }
    }
    
    func deleteProject(_ projectName: String) {
        DispatchQueue.global(qos: .background).async {
            let result = self.atlasCore.purge([projectName])
            if result.success {
                DispatchQueue.main.async(execute: {
                    self.projectListView.reloadData()
                    
                    NotificationCenter.default.post(
                        name: NSNotification.Name(rawValue: "project-deleted"),
                        object: nil
                    )
                    
                    Terminal.log("Deleted project: \(projectName)")
                })
            }
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        let projects = atlasCore.projects()
        return projects.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let project = atlasCore.projects()[indexPath.item]

        if projectListView.bounds.width < 300 {
            let item = collectionView.makeItem(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ProjectButton"),
                for: indexPath
            )
            
            guard let projectButton = item as? ProjectButton else {
                return item
            }
            
            projectButton.project = project
            projectButton.filterBy = project.name == filterByProject
            
            return projectButton
        }
        
        let item = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ProjectViewItem"),
            for: indexPath
        )
        
        guard let projectViewItem = item as? ProjectViewItem else {
            return item
        }
        
        projectViewItem.project = project        
        projectViewItem.filterBy = project.name == filterByProject

        projectViewItem.refresh()

        return projectViewItem
    }

    fileprivate func configureProjectListView() {
        projectListView.isSelectable = true
        
        resize()

        view.wantsLayer = true
    }
    
    func initObservers() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "project-added"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            if let projectName = notification.userInfo?["projectName"] as? String {
                self.addProject(projectName)
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "delete-project"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            if let projectName = notification.userInfo?["projectName"] as? String {
                self.deleteProject(projectName)
            } else {
                Terminal.log("Unable to delete project. Project name not valid.")
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "filter-project"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            if let projectName = notification.userInfo?["projectName"] as? String {
                self.filterByProject = (self.filterByProject == projectName ? nil : projectName)
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "refresh"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            self.resize()
        }        

        for notification in [
            "sync",
            "project-added",
            "project-deleted",
            "remove-file",
            "file-updated",
            "staged-file-committed"] {
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name(rawValue: notification),
                object: nil,
                queue: nil
            ) {
                (notification) in
                self.syncing(notification.userInfo?["processName"] as? String)
            }
        }
        
        for notification in [
            "sync-completed"] {
                NotificationCenter.default.addObserver(
                    forName: NSNotification.Name(rawValue: notification),
                    object: nil,
                    queue: nil
                ) {
                    (notification) in
                    if let processName = notification.userInfo?["processName"] as? String {
                        self.syncProcesses.removeValue(forKey: processName)
                    }
                }
        }
    }
    
    func resize() {
        DispatchQueue.main.async(execute: {
            let flowLayout = NSCollectionViewFlowLayout()
            
            let verticalBuffer: CGFloat = 15
            var horizontalBuffer: CGFloat = 15

            var projectHeight: CGFloat = 240
            var projectWidth: CGFloat = self.projectListView.bounds.width - (horizontalBuffer * 2.5)
            
            if self.projectListView.bounds.width > 300 {
                projectWidth = 240
            } else {
                horizontalBuffer = 0
                projectHeight = 60
                projectWidth = self.projectListView.bounds.width
            }
            
            flowLayout.itemSize = NSSize(width: projectWidth, height: projectHeight)
            flowLayout.sectionInset = NSEdgeInsets(
                top: verticalBuffer,
                left: horizontalBuffer,
                bottom: verticalBuffer,
                right: horizontalBuffer
            )
            flowLayout.minimumInteritemSpacing = horizontalBuffer
            flowLayout.minimumLineSpacing = verticalBuffer
            self.projectListView.collectionViewLayout = flowLayout

            self.projectListView.reloadData()
            
            self.projectListView.setFrameSize(
                NSSize(
                    width: self.view.frame.width,
                    height: CGFloat(self.atlasCore.projects().count) * (projectHeight + (verticalBuffer * 2))
                )
            )
        })
    }
    
    func syncing(_ processName: String?=nil) {
        DispatchQueue.main.async(execute: {
            self.statusTimer?.invalidate()
            self.syncButton.title = "Syncing..."
            if let processName = processName {
                self.syncProcesses[processName] = true
            }
            self.status.backgroundColor = NSColor.yellow
            self.statusTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
                self.showStatus()
            }
        })
    }
    
    @IBAction func clickStatus(_ sender: NSClickGestureRecognizer) {
        showStatus()

        let helpManager = NSHelpManager.shared
        helpManager.setContextHelp(NSAttributedString(string: status.toolTip ?? ""), for: status)
        helpManager.showContextHelp(for: status, locationHint: NSEvent.mouseLocation)
        helpManager.removeContextHelp(for: status)
    }
    
    
    func showStatus() {
        statusTimer?.invalidate()
        
        if syncProcesses.keys.isEmpty {
            if let atlasStatus = atlasCore.status() {
                let entries = atlasCore.syncLogEntries()
                status.toolTip = atlasStatus +
                    "\n-----------------------\n\n<STARTENTRY>" +
                    (entries.last ?? "</ENDENTRY>")
                
                if let mostRecentEntry = entries.last {
                    if !mostRecentEntry.contains("</ENDENTRY>") {
                        syncButton.title = "Syncing..."
                        status.backgroundColor = NSColor.yellow
                    } else if atlasStatus.contains("up to date") || atlasStatus.contains("up-to-date") || atlasStatus.contains("nothing to commit, working tree clean") {
                        status.backgroundColor = NSColor.green
                    } else if atlasStatus.contains("Untracked") {
                        status.backgroundColor = NSColor.yellow
                    } else {
                        status.backgroundColor = NSColor.red
                    }
                } else {
                    status.backgroundColor = NSColor.green
                }
            } else {
                status.backgroundColor = NSColor.red
            }
            
            if status.backgroundColor != NSColor.yellow {
                syncButton.title = "Sync"
            }
        }
        
        if status.backgroundColor != NSColor.green {
            statusTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
                self.showStatus()
            }
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier!.rawValue == "new-project-segue" {
            let dvc = segue.destinationController as! NewProjectController
            dvc.atlasCore = atlasCore
        }
    }

}
