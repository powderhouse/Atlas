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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureProjectListView()
        initObservers()
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func resize(_ sender: NSButton) {
        if let panels = self.parent as? NSSplitViewController {
            if let main = panels.parent {
                let newPosition = main.view.frame.width * 0.8
                panels.splitView.setPosition(newPosition, ofDividerAt: 0)
            }
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        let projects = atlasCore.projects()
        if collectionView == projectListView {
            return projects.count
        }

        let project = projects[section]
        return project.files("staged").count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ProjectViewItem"),
            for: indexPath
        )

        guard let projectViewItem = item as? ProjectViewItem else {
            return item
        }
        
        projectViewItem.project = atlasCore.projects()[indexPath.item]

        projectViewItem.refresh()

        return projectViewItem
    }

    fileprivate func configureProjectListView() {
        projectListView.isSelectable = true
        let flowLayout = NSCollectionViewFlowLayout()
        
        let projectHeight: CGFloat = 240
        let projectWidth: CGFloat = 240

        let bufferDim: CGFloat = 18
        
        flowLayout.itemSize = NSSize(width: projectWidth, height: projectHeight)
        flowLayout.sectionInset = NSEdgeInsets(top: bufferDim, left: bufferDim, bottom: bufferDim, right: bufferDim)
        flowLayout.minimumInteritemSpacing = bufferDim
        flowLayout.minimumLineSpacing = bufferDim
        projectListView.collectionViewLayout = flowLayout

        view.wantsLayer = true
        projectListView.setFrameSize(
            NSSize(
                width: view.frame.width,
                height: CGFloat(atlasCore.projects().count) * (projectHeight + (bufferDim * CGFloat(2)))
            )
        )
    }
    
    func initObservers() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "project-added"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            self.projectListView.reloadData()
        }
    }

}
