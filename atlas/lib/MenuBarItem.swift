//
//  MenuBarItem.swift
//  atlas
//
//  Created by Jared Cosulich on 1/8/18.
//  Copyright © 2018 Powderhouse Studios. All rights reserved.
//

import Cocoa

class MenuBarItem: NSObject, NSWindowDelegate, NSDraggingDestination {
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    override init() {
        super.init()
        
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            //            button.action = #selector(printQuote(_:))

            button.window?.registerForDraggedTypes([
                NSPasteboard.PasteboardType.URL,
                NSPasteboard.PasteboardType.fileURL
                ])

            button.window?.delegate = self
        }
        
    }
    
    @objc func printQuote(_ sender: Any?) {
        let quoteText = "Never put off until tomorrow what you can do the day after tomorrow."
        let quoteAuthor = "Mark Twain"
        
        print("\(quoteText) — \(quoteAuthor)")
    }
    
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let pasteboard = sender.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = pasteboard[0] as? String
            else { return false }
        
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: "add-file"),
            object: nil,
            userInfo: ["filename": path]
        )
        
        return true
    }
}


