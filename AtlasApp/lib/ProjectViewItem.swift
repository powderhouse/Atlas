 //
//  ProjectViewItem.swift
//  atlas
//
//  Created by Jared Cosulich on 12/7/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Cocoa
import AtlasCore
 
public struct ProjectFile {
    public var name: String
    public var staged: Bool
}

class ProjectViewItem: NSCollectionViewItem, NSCollectionViewDelegate, NSCollectionViewDataSource {
    
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var commitButton: NSButton!
    @IBOutlet weak var noteButton: NSButton!
    @IBOutlet weak var filterProject: NSButton!
    @IBOutlet weak var deleteButton: NSButton!
    
    @IBOutlet weak var stagedFilesView: NSCollectionView!
    
    @IBOutlet weak var stagedFilesClipView: NSClipView!
    
    @IBOutlet weak var stagedFilesScrollView: NSScrollView!
    
    @IBOutlet weak var dropView: DropView! {
        didSet {
            guard project != nil else { return }
            dropView.project = project
        }
    }
    
    var project: Project? {
        didSet {
            guard dropView != nil else { return }
            guard project != nil else { return }
            label.stringValue = project!.name
            dropView.project = project!

            identifier = NSUserInterfaceItemIdentifier(rawValue: "\(project!.name!)-staged")

            let filesViewIdentifier = NSUserInterfaceItemIdentifier(rawValue: "\(project!.name!)-staged-files")
            stagedFilesView.identifier = filesViewIdentifier
            checkCommitButton()
            
            if project?.name == AtlasCore.defaultProjectName {
                deleteButton.isHidden = true
            }
        }
    }
    
    var files: [ProjectFile] = []
    
    var filterBy: Bool {
        get {
            return dropView.layer?.backgroundColor == NSColor.black.cgColor
        }
        
        set(newValue) {
            if newValue {
                dropView.layer?.backgroundColor = NSColor.black.cgColor
                label.textColor = NSColor.white
            } else {
                dropView.layer?.backgroundColor = NSColor.gray.cgColor
                label.textColor = NSColor.black
            }
        }
    }
    
    var refreshTimer: Timer? = nil
    var refreshAttempt = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        configureStagedFileView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
        initNotifications()
        
        stagedFilesView.delegate = self
        stagedFilesView.dataSource = self
    }
    
    fileprivate func configureStagedFileView() {
        stagedFilesView.isSelectable = true
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 210, height: 30)
        flowLayout.sectionInset = NSEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        stagedFilesView.collectionViewLayout = flowLayout

        view.wantsLayer = true
    }
    
    func refresh() {
        guard refreshTimer == nil else {
            refreshAttempt = 0
            return
        }
        
        refreshTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true,
            block: { (timer) in
                if self.refreshAttempt < 10 {
                    self.stagedFilesView.reloadData()
                    self.checkCommitButton()
                    self.refreshAttempt += 1
                } else {
                    self.refreshTimer?.invalidate()
                    self.refreshTimer = nil
                    self.refreshAttempt = 0
                }
        })
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard project != nil else { return 0 }
        
        var newFiles: [ProjectFile] = []
        for fileName in project!.files("staged") {
            newFiles.append(ProjectFile(name: fileName, staged: true))
        }
        
        for fileName in project!.files("unstaged") {
            newFiles.append(ProjectFile(name: fileName, staged: false))
        }
        
        newFiles.sort { $0.name < $1.name }
        
        if newFiles.map({ "\($0.staged)-\($0.name)" }) != files.map({ "\($0.staged)-\($0.name)" }) {
            files = newFiles
        }
        
        return files.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "StagedFileViewItem"),
            for: indexPath
        )
        guard let stagedFileViewItem = item as? StagedFileViewItem else {
            return item
        }

        stagedFileViewItem.projectViewItem = self

        let file = files[indexPath.item]
        stagedFileViewItem.label.stringValue = file.name
        stagedFileViewItem.isSelected = file.staged
        stagedFileViewItem.identifier = NSUserInterfaceItemIdentifier(file.name)
        
        return stagedFileViewItem
    }
    
    func initNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "file-updated"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            if let projectName = notification.userInfo?["projectName"] as? String {
                if self.project?.name == projectName {
                    self.refresh()
                }
            }
        }

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "staged-file-committed"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            if let projectName = notification.userInfo?["projectName"] as? String {
                if self.project?.name == projectName {
                    self.refresh()
                }
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "filter-project"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            guard self.collectionView?.indexPath(for: self) != nil else {
                return
            }

            if let projectName = notification.userInfo?["projectName"] as? String {
                if projectName == self.project?.name {
                    if self.filterBy {
                        Terminal.log("Removing filter for \(projectName)")
                    } else {
                        Terminal.log("Filtering for \(projectName)")
                    }
                    self.filterBy = !self.filterBy
                } else {
                    self.filterBy = false
                }
            }
        }
    }
    
    @IBAction func commit(_ sender: NSButton) {
        let toCommit = dropView.project!.files("staged")

        guard toCommit.count != 0 else {
            Terminal.log("No files are selected to commit.")
            return
        }

        performSegue(
            withIdentifier: NSStoryboardSegue.Identifier(rawValue: "commit-project-segue"),
            sender: self
        )
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let vc = storyboard.instantiateController(
            withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "CommitController")
        ) as! CommitController
        
        self.presentViewController(vc,
           asPopoverRelativeTo: commitButton.frame,
           of: self.view,
           preferredEdge: NSRectEdge.minY,
           behavior: NSPopover.Behavior.transient
        )

        vc.toCommit = toCommit
        vc.project = dropView.project
   }
    
    @IBAction func addNote(_ sender: NSButton) {
        performSegue(
            withIdentifier: NSStoryboardSegue.Identifier(rawValue: "note-project-segue"),
            sender: self
        )
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let vc = storyboard.instantiateController(
            withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "NoteController")
        ) as! NoteController
        
        self.presentViewController(vc,
                                   asPopoverRelativeTo: noteButton.frame,
                                   of: self.view,
                                   preferredEdge: NSRectEdge.minY,
                                   behavior: NSPopover.Behavior.transient
        )
        
        vc.project = dropView.project
    }
    
    @IBAction func click(_ sender: Any) {
        if let projectName = dropView.project?.name {
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: "filter-project"),
                object: nil,
                userInfo: ["projectName": projectName]
            )
        }
    }
    
    @IBAction func delete(_ sender: NSButton) {
        let a = NSAlert()
        a.messageText = "Delete this project?"
        a.informativeText = "Are you sure you would like to delete the project?"
        a.addButton(withTitle: "Delete")
        a.addButton(withTitle: "Cancel")
        
        a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                if let projectName = self.dropView.project?.name {
                    self.label.stringValue = "Deleting..."
                    self.deleteButton.isHidden = true
                    Timer.scheduledTimer(
                        withTimeInterval: 0.1,
                        repeats: false,
                        block: { (timer) in
                            NotificationCenter.default.post(
                                name: NSNotification.Name(rawValue: "delete-project"),
                                object: nil,
                                userInfo: ["projectName": projectName]
                            )
                    })
                } else {
                    Terminal.log("Unable to delete project.")
                }
            }
        })
    }
    
    func checkCommitButton() {
        Timer.scheduledTimer(
            withTimeInterval: 0.2,
            repeats: false,
            block: { (timer) in
                self.commitButton.isEnabled = self.dropView.project!.files("staged").count > 0
                
        })
    }
}
