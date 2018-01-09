//
//  ProjectButtonViewItem.swift
//  atlas
//
//  Created by Jared Cosulich on 1/9/18.
//  Copyright © 2018 Powderhouse Studios. All rights reserved.
//

import Cocoa

class ProjectButtonViewItem: NSCollectionViewItem {

    @IBOutlet weak var projectButton: NSButton!
    
    var project: Project?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func click(_ sender: NSButton) {
        print("CLICKED \(project?.name)")
    }
}
