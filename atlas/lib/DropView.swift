//
//  DropView.swift
//  atlas
//
//  Created by Jared Cosulich on 12/10/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Cocoa

class DropView: NSView {

    weak var delegate: ProjectViewItem?
    
    var filePath: String?
    var project: Project?
//    let expectedExt = ["png"]  //file extensions allowed for Drag&Drop (example: "jpg","png","docx", etc..)
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.wantsLayer = true
        registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
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
        
        self.filePath = path
        print("SETTING: \(self.filePath)")
        project?.stageFile(URL(fileURLWithPath: path))
        
        return true
    }
}
