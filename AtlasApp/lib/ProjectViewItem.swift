//
//  ProjectViewItem.swift
//  atlas
//
//  Created by Jared Cosulich on 12/7/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Cocoa
import AtlasCore

class ProjectViewItem: NSCollectionViewItem, NSCollectionViewDelegate, NSCollectionViewDataSource {
    
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var commitButton: NSButton!
    
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
            checkCommitButton()
        }
    }
    
    var stagedFiles: [String] = []
    
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
        stagedFilesView.reloadData()
        checkCommitButton()
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard project != nil else { return 0 }
        stagedFiles = project!.files("staged")
        return stagedFiles.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "StagedFileViewItem"),
            for: indexPath
        )
        guard let stagedFileViewItem = item as? StagedFileViewItem else {
            return item
        }
        
        stagedFileViewItem.label.stringValue = stagedFiles[indexPath.item]
        stagedFileViewItem.isSelected = true
        
        return stagedFileViewItem
    }
    
    func initNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "staged-file-added"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            if let projectName = notification.userInfo?["project"] as? String {
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
            if let projectName = notification.userInfo?["project"] as? String {
                if self.project?.name == projectName {
                    self.refresh()
                }
            }
        }

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "staged-file-toggled"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            self.checkCommitButton()
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "staged-file-removed"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            if let stagedFileName = notification.userInfo?["name"] as? String {
//                self.project?.removeStagedFile(stagedFileName)
//                self.stagedFilesView.reloadData()
                self.checkCommitButton()
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

    func checkCommitButton() {
        Timer.scheduledTimer(
            withTimeInterval: 0.2,
            repeats: false,
            block: { (timer) in
                self.commitButton.isEnabled = self.dropView.project!.files("staged").count > 0
                
        })
    }
}