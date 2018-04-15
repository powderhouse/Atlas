//
//  ProjectButton.swift
//  AtlasApp
//
//  Created by Jared Cosulich on 4/14/18.
//

import Cocoa
import AtlasCore

class ProjectButton: NSCollectionViewItem {

    @IBOutlet weak var button: NSButton!
    
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
            button.title = project!.name
            dropView.project = project!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func select(_ sender: Any) {
    }
    
    
}
