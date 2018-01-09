//
//  SideDrag.swift
//  atlas
//
//  Created by Jared Cosulich on 1/9/18.
//  Copyright © 2018 Powderhouse Studios. All rights reserved.
//

import Cocoa

class SideDrop {
    
    var window: NSWindow?
    var contentController: DropAreaController?
    var dragStart: NSPoint? = nil
    
    init() {
        initDragTracking()
        
    }
    
    func initDragTracking() {
        NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDragged) { (event) in
            self.trackDragging(event)
        }

        NSEvent.addLocalMonitorForEvents(matching: .leftMouseDragged) { (event) -> NSEvent? in
            self.trackDragging(event)
            return event
        }

        NSEvent.addGlobalMonitorForEvents(matching: .leftMouseUp) { (event) in
            self.dragStart = nil

            _ = Timer.scheduledTimer(
                withTimeInterval: 0.1,
                repeats: false,
                block: { (timer) in
                    if self.window?.isVisible ?? false {
                        print("FILE: \(self.contentController?.dropView.filePath)")
                        self.window?.close()
                    }
            })
        }
    }
    
    func trackDragging(_ event: NSEvent) {
        let current = event.locationInWindow
        
        guard dragStart != nil else {
            dragStart = current
            return
        }
        
        let moved = (abs(dragStart!.x - current.x) > 20) || (abs(dragStart!.y - current.y) > 20)
        if abs(current.x) < 100 && moved {
            self.showDropArea(current)
        }
    }
    
    func showDropArea(_ center: NSPoint) {
        if window == nil {
            let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
            let identifier = NSStoryboard.SceneIdentifier(rawValue: "DropAreaWindow")
            let windowController = storyboard.instantiateController(withIdentifier: identifier) as! DropAreaWindowController
            window = windowController.window
            contentController = windowController.contentViewController as? DropAreaController
        }
        
        let x = center.x - (window!.frame.width / 2)
        let y = center.y - (window!.frame.height / 2)

        window?.setFrameOrigin(NSPoint(x: x, y: y))
        window?.windowController?.showWindow(self)
    }
}
