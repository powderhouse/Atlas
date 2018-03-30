//
//  DropView.swift
//  atlas
//
//  Created by Jared Cosulich on 12/10/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Cocoa
import AtlasCore

class DropView: NSView {
    
    var filePath: String?
    var project: Project?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.wantsLayer = true
        registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        self.layer?.backgroundColor = NSColor.green.cgColor
        return .copy
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0).cgColor
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        self.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0).cgColor
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let pasteboard = sender.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = pasteboard[0] as? String
            else { return false }
        
        guard project != nil else { return false }
        
        self.filePath = path
        if project!.copyInto([path]) {
            let filename = URL(fileURLWithPath: path).lastPathComponent
            Terminal.log("Imported \(filename) into \(project!.name!)")
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: "staged-file-added"),
                object: nil,
                userInfo: ["project": project!.name!])
            return true
        }
        return false
    }
}
