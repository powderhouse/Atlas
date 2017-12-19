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
    var ready = false
    var logging = false
    
    init(_ view: NSTextView) {
        self.view = view

        super.init()
        
        view.delegate = self
        clear()
        
        initObservers()
        initCommands()
        
        Timer.scheduledTimer(
            withTimeInterval: 3,
            repeats: false
        ) { (timer) in
            self.ready = true
        }
    }
    
    func initCommands() {
        
    }
    
    func textDidChange(_ notification: Notification) {
        guard !logging else {
            return
        }
        
        if var text = view.textStorage?.string {
            let lastCharacter = text.removeLast()
            if lastCharacter == "\n" {
                if let commandStart = text.range(of: "> ", options: .backwards)?.upperBound {
                    let command = String(text.suffix(from: commandStart))
                    runCommand(command)
                }
            }
        }
    }
    
    func runCommand(_ fullCommand: String) {
        var allArgs = fullCommand.split(separator: " ")
        let command = String(allArgs.removeFirst())
        
        switch command {
        case "status":
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: "git-status"),
                object: self
            )
        case "stage":
            print("STAGE: \(allArgs.joined(separator: " "))")
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: "git-stage"),
                object: self,
                userInfo: ["path": allArgs.joined(separator: " ")]
            )
        default:
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: "raw-command"),
                object: self,
                userInfo: ["command": fullCommand]
            )
        }
        
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

        guard ready else {
            Timer.scheduledTimer(
                withTimeInterval: 0.2,
                repeats: false,
                block: { (timer) in
                    self.dequeueLog()
            })
            return
        }
        
        var text = self.queue.removeFirst()
        
        guard text.count != 0 else {
            return
        }
        
        logging = true
        
        var range = self.view.selectedRange()
        if view.textStorage?.string.suffix(2) == "> " {
            range.location = range.location - 2
            range.length = 2
        } else {
            text = "\n\(text)"
        }
        
        text = "\(text)\n\n> ".replacingOccurrences(of: "\n\n\n", with: "\n", options: .literal, range: nil)
        
        self.view.insertText(text, replacementRange: range)
        
        logging = false
        
        queueTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: false
        ) { (timer) in
            self.queueTimer = nil
            self.dequeueLog()
        }
    }
}
