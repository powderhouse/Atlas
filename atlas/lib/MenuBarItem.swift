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
    
    var filePath: String? = nil
    
    var projects: Projects!
    
    init(_ projects: Projects) {
        super.init()
        
        self.projects = projects

//        constructMenu()
        
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
//            button.action = #selector(printQuote)
            
            button.window?.registerForDraggedTypes([
                NSPasteboard.PasteboardType.URL,
                NSPasteboard.PasteboardType.fileURL
                ])

            button.window?.delegate = self
        }
    }
    
    func constructMenu() {
        let menu = NSMenu()
        
        let menuItem = NSMenuItem(title: "Print Quote", action: #selector(printQuote), keyEquivalent: "P")
        menu.addItem(menuItem)
        menu.addItem(NSMenuItem.separator())
        
//        for project in projects.list() {
//            initProjectMenuItem(menu, project: project)
//            menu.addItem(NSMenuItem.separator())
//        }
        
        statusItem.menu = menu
    }
    
    func initProjectMenuItem(_ menu: NSMenu, project: Project) {
        let character = "\(project.name.first)"
        print("CHARACTER: \(character)")
        
        let menuItem = NSMenuItem(
            title: project.name,
            action: #selector(sendToProject(_:)),
            keyEquivalent: character
        )
        menuItem.isEnabled = true
        menu.addItem(menuItem)
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
        statusItem.popUpMenu(statusItem.menu!)
        
        return true
    }
    
}


