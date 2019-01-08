//
//  CommitFileViewItem.swift
//  AtlasApp
//
//  Created by Jared Cosulich on 1/3/19.
//

import Cocoa
import AtlasCore
import WebKit

class CommitFileViewItem: NSCollectionViewItem {
    
    @IBOutlet weak var image: NSImageView!
    @IBOutlet weak var fileLink: NSButton!
    @IBOutlet weak var removeButton: NSButton!
    
    var project: Project?
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
    
    @IBAction func clickFile(_ sender: NSButton) {
        performSegue(
            withIdentifier: NSStoryboardSegue.Identifier(rawValue: "preview-segue"),
            sender: self
        )
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let vc = storyboard.instantiateController(
            withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "PreviewController")
            ) as! PreviewController
        
        if let size = NSScreen.screens.first?.frame.size {
            vc.preferredContentSize = size.applying(CGAffineTransform(scaleX: 0.8, y: 0.8))
        }
        
        self.presentViewController(vc,
                                   asPopoverRelativeTo: fileLink.frame,
                                   of: self.view,
                                   preferredEdge: NSRectEdge.minY,
                                   behavior: NSPopover.Behavior.transient
        )
        
        vc.url = url
        vc.webView.load(URLRequest(url: url!))
    }
    
    
    @IBAction func remove(_ sender: NSButton) {
        let a = NSAlert()
        a.messageText = "Remove this file?"
        a.informativeText = "Are you sure you would like to remove this file?"
        a.addButton(withTitle: "Remove")
        a.addButton(withTitle: "Cancel")
        
        a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                if let project = self.project {
                    let file = "\(project.name!)/\(Project.committed)/\(self.fileLink.stringValue)"
                    NotificationCenter.default.post(
                        name: NSNotification.Name(rawValue: "remove-file"),
                        object: nil,
                        userInfo: [
                            "file": file,
                            "projectName": project.name
                        ]
                    )
                } else {
                    Terminal.log("Project not found.")
                }
            }
        })
    }
}
