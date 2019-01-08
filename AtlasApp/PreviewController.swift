//
//  PreviewController.swift
//  AtlasApp
//
//  Created by Jared Cosulich on 1/4/19.
//

import Cocoa
import AtlasCore
import WebKit

class PreviewController: NSViewController {
    
    @IBOutlet var webView: WKWebView!
    
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
//        let frame = self.view.frame
//        let view = NSView(frame: frame)
        
        self.view.wantsLayer = true
        
        self.view.layer?.backgroundColor = NSColor.black.cgColor
    }
    
    @IBAction func close(_ sender: NSButton) {
        self.dismiss(self)
    }

    @IBAction func download(_ sender: NSButton) {
        if let url = url {
            NSWorkspace.shared.open(url)
        }
    }

}
