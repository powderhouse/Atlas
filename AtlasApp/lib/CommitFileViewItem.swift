//
//  CommitFileViewItem.swift
//  AtlasApp
//
//  Created by Jared Cosulich on 1/3/19.
//

import Cocoa
import AtlasCore
import WebKit
import Quartz

class AtlasQLPreviewItem: NSObject, QLPreviewItem {
    var previewItemURL: URL!
    var previewItemTitle: String
    init(url: URL, title: String) {
        self.previewItemURL = url
        self.previewItemTitle = title
    }
}

class CommitFileViewItem: NSCollectionViewItem {
    
    @IBOutlet weak var fileLink: NSButton!
    @IBOutlet weak var removeButton: NSButton!
    
    var project: Project!
    var url: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
    
    override func prepareForReuse() {
        project = nil
        imageView?.image = nil
        super.prepareForReuse()
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
        vc.previewView.frame = vc.webView.frame

        vc.url = self.url
        vc.webView.load(URLRequest(url: self.url))

        vc.previewView.previewItem = AtlasQLPreviewItem(
            url: URL(fileURLWithPath: "/Users/jcosulich/Library/Containers/powderhs.AtlasApp/Data/Library/Application Support/Atlas/atlastestaccount2/Atlas/tiny-schools-4pt0-v4.pdf"),
            title: fileLink.title
        )
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
                    if let file = self.url.relativeString.components(separatedBy: "\(project.name!)/\(Project.committed)/").last {
                        let relativePath = "\(project.name!)/\(Project.committed)/\(file)"
                        NotificationCenter.default.post(
                            name: NSNotification.Name(rawValue: "remove-file"),
                            object: nil,
                            userInfo: [
                                "file": relativePath,
                                "projectName": project.name
                            ]
                        )
                    }
                } else {
                    Terminal.log("Project not found.")
                }
            }
        })
    }
}
