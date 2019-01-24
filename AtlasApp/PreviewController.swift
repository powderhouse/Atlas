//
//  PreviewController.swift
//  AtlasApp
//
//  Created by Jared Cosulich on 1/4/19.
//

import Cocoa
import AtlasCore
import WebKit
import Quartz

class PreviewController: NSViewController {
    
    @IBOutlet var webView: WKWebView!
    
    var previewView: QLPreviewView!
    
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.view.wantsLayer = true
        
        self.view.layer?.backgroundColor = NSColor.black.cgColor
        
        self.previewView = QLPreviewView(frame: webView.frame, style: .compact)
        self.view.addSubview(previewView)

        for constraint in webView.constraints {
            self.previewView.addConstraint(constraint)
        }
        previewView.isHidden = true
    }
    
    @IBAction func close(_ sender: NSButton) {
        self.dismiss(self)
    }

    @IBAction func download(_ sender: NSButton) {
       
//        if let url = url {
//            NSWorkspace.shared.open(url)
//        }

        if let url = url {
            let downloadTask = URLSession.shared.downloadTask(with: url) {
                urlOrNil, responseOrNil, errorOrNil in
                guard let fileURL = urlOrNil else { return }
                do {
                    let documentsURL = try
                        FileManager.default.url(for: .downloadsDirectory,
                                                in: .userDomainMask,
                                                appropriateFor: nil,
                                                create: false)
                    let savedURL = documentsURL.appendingPathComponent(
                        url.lastPathComponent)
                    try FileManager.default.moveItem(at: fileURL, to: savedURL)
                } catch {
                    print ("file error: \(error)")
                }
            }
            downloadTask.resume()
        }
    }

}
