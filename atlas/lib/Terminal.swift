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
    let notificationCenter: AtlasNotificationCenter!
    var queue: [String] = []
    var queueTimer: Timer?
    var ready = false
    var logging = false
    var minCursorPosition = 0
    
    init(_ view: NSTextView, notificationCenter: AtlasNotificationCenter?=NotificationCenter.default) {
        self.view = view
        self.notificationCenter = notificationCenter

        super.init()
        
        view.delegate = self
        clear()
        
        initObservers()
        
        Timer.scheduledTimer(
            withTimeInterval: 3,
            repeats: false
        ) { (timer) in
            self.ready = true
        }
    }
    
    func textViewDidChangeSelection(_ notification: Notification) {
        view.isEditable = (view.selectedRange().lowerBound >= minCursorPosition)
    }
    
    func textDidChange(_ notification: Notification) {
        guard !logging else {
            return
        }
        
        if var text = view.textStorage?.string {
            if text.count < minCursorPosition {
                var range = self.view.selectedRange()
                range.location = range.location - 1
                range.length = 1
                view.isEditable = true
                view.insertText("> ", replacementRange: range)
                return
            }
            
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
        let command = String(allArgs.removeFirst().lowercased())
        
        switch command {
        case "status":
            notificationCenter.post(
                name: NSNotification.Name(rawValue: "git-status"),
                object: self
            )
        case "stage":
            let path = allArgs.joined(separator: " ")
            notificationCenter.post(
                name: NSNotification.Name(rawValue: "git-stage"),
                object: self,
                userInfo: ["path": removeQuotes(path)]
            )
        case "commit":
            let message = allArgs.joined(separator: " ")
            
            notificationCenter.post(
                name: NSNotification.Name(rawValue: "git-commit"),
                object: self,
                userInfo: ["message": removeQuotes(message)]
            )
        case "clear":
            self.clear()
        case "atlas":
            let atlasCommand = allArgs.removeFirst().lowercased()
            
            switch atlasCommand {
            case "log":
                notificationCenter.post(
                    name: NSNotification.Name(rawValue: "git-log-name-only"),
                    object: self
                )
            default:
                Terminal.log("Unknown Atlas Command")
            }
        default:
            notificationCenter.post(
                name: NSNotification.Name(rawValue: "raw-command"),
                object: self,
                userInfo: ["command": fullCommand]
            )
        }
        
    }
    
    func removeQuotes(_ text: String) -> String {
        var processedText = text
        let quotes = ["\"", "\u{201C}", "\u{201D}"]
        if quotes.contains("\(text.first ?? "x")") {
            _ = processedText.removeFirst()
        }
        
        if quotes.contains("\(text.last ?? "x")") {
            _ = processedText.removeLast()
        }
        return processedText
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
        minCursorPosition = 0
        view.selectAll(self)
        let range = view.selectedRange()
        view.insertText("> ", replacementRange: range)
        minCursorPosition = 2
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
        
        minCursorPosition = (self.view.textStorage?.string ?? "").count
        
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
