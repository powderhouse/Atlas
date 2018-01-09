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
    
    var projects: Projects!
    
    init(_ projects: Projects) {
        initDragTracking()
        self.projects = projects
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
                        self.window = nil
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
        
        let screenWidth = NSScreen.main?.frame.width ?? 0
        let side = (abs(current.x) < 100) || (abs(screenWidth - current.x) < 100)
        let moved = (abs(dragStart!.x - current.x) > 20) || (abs(dragStart!.y - current.y) > 20)
        if side && moved {
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
            contentController?.projects = projects
        }
        
        let x = center.x - (window!.frame.width / 2)
        let y = center.y - (window!.frame.height / 2)

        window?.setFrameOrigin(NSPoint(x: x, y: y))
        window?.windowController?.showWindow(self)
    }
}
