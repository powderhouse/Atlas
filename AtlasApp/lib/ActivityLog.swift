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
        view.reloadData()
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        commits = atlasCore.log()
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

        commitViewItem.project.stringValue = commit.projects.map {$0.name }.joined(separator: ", ")
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
        
        return commitViewItem
    }
    
    func initObservers() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "staged-file-committed"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            self.refresh()
        }
    }
    
    func configure() {
        view.isSelectable = false
        let flowLayout = NSCollectionViewFlowLayout()
        
        let commitHeight = CGFloat(200)
        let commitWidth = CGFloat(view.frame.width - 100)
        let bufferDim = CGFloat(12)
        
        flowLayout.itemSize = NSSize(width: commitWidth, height: commitHeight)
        flowLayout.sectionInset = NSEdgeInsets(top: bufferDim, left: bufferDim, bottom: bufferDim, right: bufferDim)
        flowLayout.minimumInteritemSpacing = bufferDim
        flowLayout.minimumLineSpacing = bufferDim
        view.collectionViewLayout = flowLayout
        
        view.wantsLayer = true
        
        view.setFrameSize(
            NSSize(
                width: view.frame.width,
                height: CGFloat(commits.count) * (commitHeight + (bufferDim * CGFloat(2)))
            )
        )
    }
    
}