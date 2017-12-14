//
//  Terminal.swift
//  atlas
//
//  Created by Jared Cosulich on 12/14/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

//import Foundation
import Cocoa

class Terminal: NSObject, NSTextViewDelegate, NSTextDelegate {
    
    let view: NSTextView!
    var queue: [String] = []
    var queueTimer: Timer?
    
    init(_ view: NSTextView) {
        self.view = view

        super.init()
        
        view.delegate = self
        clear()
        
        initObservers()
    }
    
    func initObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(log),
            name: NSNotification.Name(rawValue: "log"),
            object: nil
        )
    }
    
    func clear() {
        view.selectAll(self)
        let range = view.selectedRange()
        view.insertText("> ", replacementRange: range)
    }
    
    class func log(_ text: String) {
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: "log"),
            object: nil,
            userInfo: ["text": text]
        )
    }
    
    @objc func log(notification: Notification) {
        if let text = notification.userInfo?["text"] as? String {
            queue.append(text)
        }
        dequeueLog()
    }
    
    func dequeueLog() {
        guard !queue.isEmpty else {
            return
        }
        
        guard queueTimer == nil else {
            return
        }
        
        queueTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: false
        ) { (timer) in
                let text = self.queue.removeFirst()
                
                guard text.count != 0 else {
                    return
                }
            
                var range = self.view.selectedRange()
                range.location = range.location - 2
                self.view.insertText("\(text)\n\n> ", replacementRange: range)
                self.queueTimer = nil
                print("QUEUE: \(self.queue)")
                self.dequeueLog()
        }
    }
}
