//
//  ActivityLog.swift
//  atlas
//
//  Created by Jared Cosulich on 1/13/18.
//  Copyright © 2018 Powderhouse Studios. All rights reserved.
//

import Cocoa
import AtlasCore

class ActivityLog: NSObject, NSCollectionViewDelegate, NSCollectionViewDataSource {
    
    var view: NSCollectionView!
    var atlasCore: AtlasCore!
    var commits: [Commit] = []
    
    let commitHeight = CGFloat(200)
    let bufferDim = CGFloat(12)
    
    var selectedProject: String? {
        didSet {
            refresh()
        }
    }
    
    var searchTerms: [String] = []
    var searchResults: [NSURL]? = nil
    
    init(_ view: NSCollectionView, atlasCore: AtlasCore) {
        super.init()
        
        self.atlasCore = atlasCore
        self.view = view
        
        view.delegate = self
        view.dataSource = self
        
        configure()
        initObservers()
    }
    
    func refresh() {
        view.reloadSections(IndexSet(integer: 0))
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func commitSlugFilter() -> [String]? {
        guard searchResults != nil else { return nil }
        
        var slugs: [String] = []
        for result in searchResults! {
            if let slug = result.deletingLastPathComponent?.lastPathComponent {
                if !slugs.contains(slug) {
                    slugs.append(slug)
                }
            }
        }
        return slugs
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        commits = atlasCore.log(projectName: selectedProject, commitSlugFilter: commitSlugFilter())
        setFrameSize()
        return commits.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {

        let item = view.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CommitViewItem"),
            for: indexPath
        )

        guard let commitViewItem = item as? CommitViewItem else {
            return item
        }

        let commit = commits.reversed()[indexPath.item]

        let projectNames =  Array(Set(commit.projects.map { $0.name }))
        commitViewItem.project.stringValue = projectNames.joined(separator: ", ")
        commitViewItem.subject.stringValue = commit.message
        
        if let filesField = commitViewItem.files {
            filesField.isEditable = true
            filesField.selectAll(self)
            let range = filesField.selectedRange()
            filesField.insertText("", replacementRange: range)
            
            for file in commit.files {
                var range = filesField.selectedRange()
                
                let link = NSAttributedString(
                    string: file.name,
                    attributes: [NSAttributedStringKey.link: file.url]
                )

                filesField.insertText("\n", replacementRange: range)
                range.location = range.location + 2
                filesField.insertText(link, replacementRange: range)
            }
            
            filesField.isEditable = false
        }
        
        let fileNames = self.searchResults?.flatMap({ $0.lastPathComponent })
        commitViewItem.highlightFiles(fileNames ?? [])
        commitViewItem.highlight(self.searchTerms)

        return commitViewItem
    }
    
    func initObservers() {
        
        for notification in [
            "staged-file-committed",
            "project-deleted"] {
                NotificationCenter.default.addObserver(
                    forName: NSNotification.Name(rawValue: notification),
                    object: nil,
                    queue: nil
                ) {
                    (notification) in
                    self.refresh()
                }
        }        
    }
    
    func configure() {
        view.isSelectable = false
        let flowLayout = NSCollectionViewFlowLayout()
        
        flowLayout.itemSize = NSSize(width:  CGFloat(view.frame.width - 100), height: commitHeight)
        flowLayout.sectionInset = NSEdgeInsets(top: bufferDim, left: bufferDim, bottom: bufferDim, right: bufferDim)
        flowLayout.minimumInteritemSpacing = bufferDim
        flowLayout.minimumLineSpacing = bufferDim
        view.collectionViewLayout = flowLayout
        
        view.wantsLayer = true
        setFrameSize()
    }
    
    func setFrameSize() {
        view.setFrameSize(
            NSSize(
                width: view.frame.width,
                height: CGFloat(commits.count) * (commitHeight + (bufferDim * CGFloat(2)))
            )
        )
    }
    
}
