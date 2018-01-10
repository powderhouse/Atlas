//
//  SideDrag.swift
//  atlas
//
//  Created by Jared Cosulich on 1/9/18.
//  Copyright © 2018 Powderhouse Studios. All rights reserved.
//

import Cocoa

class SideDrop {
    
    let sideBuffer = CGFloat(400)
    let movementBuffer = CGFloat(10)
    
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
                    if (self.window?.isVisible ?? false) && (self.contentController != nil) {
                        if !self.contentController!.showProjectOptions() {
                            self.closeWindow()
                        }
                    }
            })
        }
    }
    
    func closeWindow() {
        guard window != nil else { return }
        window!.close()
        window = nil
    }
    
    func trackDragging(_ event: NSEvent) {
        let current = event.locationInWindow
        
        guard dragStart != nil else {
            if window != nil {
                closeWindow()
            }
            dragStart = current
            return
        }
        
        let screenWidth = NSScreen.main?.frame.width ?? 0
        let side = (abs(current.x) < sideBuffer) ||
                   (abs(screenWidth - current.x) < sideBuffer)
        let moved = (abs(dragStart!.x - current.x) > movementBuffer) ||
                    (abs(dragStart!.y - current.y) > movementBuffer)
        
        if side && moved {
            self.showDropArea(current)
        }
    }
    
    func showDropArea(_ center: NSPoint) {
        guard window == nil else { return }

        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "DropAreaWindow")
        let windowController = storyboard.instantiateController(withIdentifier: identifier) as! DropAreaWindowController
        window = windowController.window
        contentController = windowController.contentViewController as? DropAreaController
        contentController?.projects = projects
        contentController?.window = window
        
        let screenWidth = NSScreen.main?.frame.width ?? 0
        var x = window!.frame.width * -1
        if center.x > sideBuffer {
            x = screenWidth - window!.frame.width
        }
        
        let screenHeight = NSScreen.main?.frame.height ?? 0
        let y = (screenHeight / 2) - (window!.frame.height / 2)

        window?.setFrameOrigin(NSPoint(x: x, y: y))
        windowController.showWindow(self)
    }
}
