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
    
    func addProject(_ projectName: String) {
        _ = atlasCore.initProject(projectName)
        _ = atlasCore.atlasCommit()
        projectListView.reloadData()
        Terminal.log("Added project: \(projectName)")
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
            forName: NSNotification.Name(rawValue: "filter-project"),
            object: nil,
            queue: nil
        ) {
            (notification) in
            if let projectName = notification.userInfo?["projectName"] as? String {
                self.filterByProject = (self.filterByProject == projectName ? nil : projectName)
            }
        }
    }
    
    func resize() {
        let flowLayout = NSCollectionViewFlowLayout()
        
        let verticalBuffer: CGFloat = 15
        var horizontalBuffer: CGFloat = 15

        var projectHeight: CGFloat = 240
        var projectWidth: CGFloat = projectListView.bounds.width - (horizontalBuffer * 2.5)
        
        if projectListView.bounds.width > 300 {
            projectWidth = 240
        } else {
            horizontalBuffer = 0
            projectHeight = 60
            projectWidth = projectListView.bounds.width
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
        projectListView.collectionViewLayout = flowLayout

        projectListView.reloadData()
        
        projectListView.setFrameSize(
            NSSize(
                width: view.frame.width,
                height: CGFloat(atlasCore.projects().count) * (projectHeight + (verticalBuffer * 2))
            )
        )
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier?.rawValue == "new-project-segue" {
            let dvc = segue.destinationController as! NewProjectController
            dvc.atlasCore = atlasCore
        }
    }

}
