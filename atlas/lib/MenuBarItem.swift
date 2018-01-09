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
    
    var menuBarItemController: MenuBarItemController?
    
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
        
        menuBarItemController = MenuBarItemController.freshController()
        menuBarItemController!.projects = projects
        menuBarItemController!.popover = popover
        popover.contentViewController = menuBarItemController!
    }
    
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let pasteboard = sender.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = pasteboard[0] as? String
            else { return false }
        
        self.filePath = path
        menuBarItemController!.filePath = filePath
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }

        return true
    }
}


