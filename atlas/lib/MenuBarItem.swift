//
//  MenuBarItem.swift
//  atlas
//
//  Created by Jared Cosulich on 1/8/18.
//  Copyright © 2018 Powderhouse Studios. All rights reserved.
//

import Cocoa

class MenuBarItem: NSObject, NSWindowDelegate, NSDraggingDestination {
    
    let popover = NSPopover()
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    var filePath: String? = nil
    
    var projects: Projects!
    
    init(_ projects: Projects) {
        super.init()
        
        self.projects = projects

        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            
            button.window?.registerForDraggedTypes([
                NSPasteboard.PasteboardType.URL,
                NSPasteboard.PasteboardType.fileURL
                ])

            button.window?.delegate = self
        }
        
        let menuBarItemController = MenuBarItemController.freshController()
        menuBarItemController.projects = projects
        popover.contentViewController = menuBarItemController
    }
    
    @objc func sendToProject(_ sender: Any?) {
        guard filePath != nil else { return }
        print("SENDER: \(sender)")
//        let projectName = sender.title
//
//        if let project = projects.list().first(where: { $0.name == projectName }) {
//            project.stageFile(URL(fileURLWithPath: self.filePath!))
//        }
    }
    
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let pasteboard = sender.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = pasteboard[0] as? String
            else { return false }
        
        self.filePath = path
        showPopover(sender: self)
        
        return true
    }
    
    @objc func togglePopover(_ sender: Any?) {
        print("POPOVER")
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
    }
    
}


