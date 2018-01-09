//
//  DropAreaController.swift
//  atlas
//
//  Created by Jared Cosulich on 1/9/18.
//  Copyright © 2018 Powderhouse Studios. All rights reserved.
//

import Cocoa

class DropAreaController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource {
    
    @IBOutlet weak var dropView: DropView!
    
    @IBOutlet weak var projectButtonsView: NSCollectionView!
    
    var popover: NSPopover?
    var projects: Projects?
    var filePath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
//        configureCollectionViews()
    }
    
    func setProjects(_ projects: Projects) {
        self.projects = projects
        projectButtonsView.reloadData()
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return projects?.list().count ?? 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ProjectButtonViewItem"),
            for: indexPath
        )
        guard let projectButtonViewItem = item as? ProjectButtonViewItem else {
            return item
        }
        
//        if let project = projects?.list()[indexPath.item] {
//            projectButtonViewItem.project = project
//        }
//
//        projectButtonViewItem.popover = popover
//        projectButtonViewItem.filePath = filePath
        
        return projectButtonViewItem
    }
    
    //    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    //        print("SELECTED!")
    //        if let selectedIndex = indexPaths.first?.item {
    //            if let project = projects?.list()[selectedIndex] {
    //                print("PROJECT SELECTED: \(project.name)")
    //            }
    //        }
    //    }
    
    fileprivate func configureCollectionViews() {
        projectButtonsView.isSelectable = true
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 120.0, height: 40.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 10.0
        projectButtonsView.collectionViewLayout = flowLayout
        
        view.wantsLayer = true
        
        projectButtonsView.layer?.backgroundColor = NSColor.black.cgColor
    }
}


