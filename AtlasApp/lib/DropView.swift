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
    
    var filePromiseProcessingCount = 0
    
    /// queue used for reading and writing file promises
    private lazy var workQueue: OperationQueue = {
        let providerQueue = OperationQueue()
        providerQueue.qualityOfService = .userInitiated
        return providerQueue
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.wantsLayer = true
        
        var dragTypes = [NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL]
        dragTypes += NSFilePromiseReceiver.readableDraggedTypes.map { NSPasteboard.PasteboardType($0) }
        registerForDraggedTypes(dragTypes)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        highlight()
        return .copy
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        stopHighlight()
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        stopHighlight()
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard project != nil else { return false }

        highlight()
        sender.enumerateDraggingItems(options: [], for: self, classes: [NSFilePromiseReceiver.self], searchOptions: [:], using: {(draggingItem, idx, stop) in
            
            if let filePromiseReceiver = draggingItem.item as? NSFilePromiseReceiver {
                self.filePromiseProcessingCount += 1
                if let stagedDirectory = self.project?.directory(Project.staged) {
                    filePromiseReceiver.receivePromisedFiles(
                        atDestination: stagedDirectory,
                        options: [:],
                        operationQueue: self.workQueue
                    ) { (fileURL, error) in
                        Terminal.log("Processing file...")
                        if let error = error {
                            Terminal.log("Unable to process file: \(error)")
                        } else {
                            self.processPaths([fileURL.path])
                        }
                        
                        self.filePromiseProcessingCount -= 1
                        if self.filePromiseProcessingCount == 0 {
                            DispatchQueue.main.async(execute: {
                                self.stopHighlight()
                            })
                        }
                    }
                }
            }
        })
        
        if filePromiseProcessingCount == 0 {
            if let paths = sender.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? [String] {
                processPaths(paths)
            }
        
            stopHighlight()
        }
        
        return true
    }
    
    func highlight() {
        layer?.backgroundColor = NSColor.green.cgColor
    }
    
    func stopHighlight() {
        guard filePromiseProcessingCount == 0 else {
            return
        }
        self.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0).cgColor
    }
    
    func processPaths(_ paths: [String]) {
        DispatchQueue.global(qos: .background).async {
            let result = self.project!.copyInto(paths)
            if result.success {
                DispatchQueue.main.async(execute: {
                    Terminal.log("Imported files into \(self.project!.name!)")
                    NotificationCenter.default.post(
                        name: NSNotification.Name(rawValue: "file-updated"),
                        object: nil,
                        userInfo: ["projectName": self.project!.name!]
                    )
                })
            }
        }
    }
}
