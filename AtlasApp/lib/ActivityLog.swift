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
    
    var images: [String: NSImage] = [:]
    
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
        DispatchQueue.main.async(execute: {
            self.view.reloadSections(IndexSet(integer: 0))
        })
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
        commitViewItem.commit = commit
        
        for file in commit.files {
            if let fileExtension = file.name.components(separatedBy: ".").last {
                if !["png", "jpg", "jpeg", "gif", "pdf"].contains(fileExtension) {
                    continue
                }
            }
            
            if let image = images[file.url] {
                commitViewItem.images[file.url] = image
            } else {
                DispatchQueue.global(qos: .background).async {
                    var image: NSImage? = nil
                    if let imageUrl = URL(string: file.url) {
                        if let data = try? Data(contentsOf: imageUrl) {
                            image = NSImage(data: data)
                            image?.size = NSSize(width: 30, height: 30)
                            self.images[file.url] = image
                            commitViewItem.images[file.url] = image
                        }
                    }
                }
            }
        }
        
        let fileNames = self.searchResults?.compactMap({ $0.lastPathComponent })
        commitViewItem.highlightFiles(fileNames ?? [])
        commitViewItem.highlight(self.searchTerms)

        return commitViewItem
    }
    
    func initObservers() {
        for notification in [
            "staged-file-committed",
            "staged-file-commit-complete",
            "project-deleted",
            "file-updated",
            "refresh"] {
                NotificationCenter.default.addObserver(
                    forName: NSNotification.Name(rawValue: notification),
                    object: nil,
                    queue: nil
                ) {
                    (notification) in
                    if notification.name.rawValue == "staged-file-committed" {
                        Terminal.log("Syncing with S3. Depending on the size of the file this could take a while...")
                    }
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
        DispatchQueue.main.async(execute: {
            self.view.setFrameSize(
                NSSize(
                    width: self.view.frame.width,
                    height: CGFloat(self.commits.count) * (self.commitHeight + (self.bufferDim * CGFloat(2)))
                )
            )
        })
    }
    
}
