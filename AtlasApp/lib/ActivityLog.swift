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
    
    func configure() {
        view.isSelectable = false
        let flowLayout = NSCollectionViewFlowLayout()        
        flowLayout.itemSize = NSSize(width: view.frame.width - 40, height: 200)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        view.collectionViewLayout = flowLayout
        
        view.wantsLayer = true        
    }
    
}
