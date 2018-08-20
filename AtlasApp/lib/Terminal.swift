//
//  Terminal.swift
//  AtlasApp
//
//  Created by Jared Cosulich on 3/14/18.
//

import Cocoa
import AtlasCore

class Terminal: NSObject, NSTextViewDelegate, NSTextDelegate, NSTextFieldDelegate {
    
    let atlasCore: AtlasCore!
    let output: NSTextView!
    let input: NSTextField!
    let notificationCenter: AtlasNotificationCenter!
    var queue: [String] = []
    var queueTimer: Timer?
    var logging = false
    var minCursorPosition = 0
    
    init(input: NSTextField, output: NSTextView, atlasCore: AtlasCore, notificationCenter: AtlasNotificationCenter?=NotificationCenter.default) {
        self.input = input
        self.output = output
        self.notificationCenter = notificationCenter
        self.atlasCore = atlasCore
        
        super.init()
        
        output.delegate = self
        output.isEditable = false
        
        input.delegate = self
        
        clear()
        
        initObservers()

        output.isEditable = false
    }
    
    func control(_ control: NSControl,
                 textView: NSTextView,
                 doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector.description == "insertNewline:" {
            runCommand(input.stringValue)
            input.stringValue = ""
            return true
        }
        return false
    }
    
    func runCommand(_ fullCommand: String) {
        var allArgs = fullCommand.split(separator: " ")
        
        guard allArgs.count != 0 else {
            Terminal.log("Please enter a command")
            return
        }
        
        let command = String(allArgs.removeFirst().lowercased())
        
        switch command {
        case "status":
            Terminal.log(atlasCore.status() ?? "N/A")
        case "stage":
            if let projectFlagIndex = allArgs.index(where: { $0 == "-p" || $0 == "--project" }) {
                let projectName = String(allArgs[projectFlagIndex + 1])
                if let project = atlasCore.project(projectName) {
                    if let filesFlagIndex = allArgs.index(where: { $0 == "-f" || $0 == "--files" }) {
                        var filesIndex = filesFlagIndex + 1
                        var files: [String] = []
                        while filesIndex < allArgs.endIndex && !String(allArgs[filesIndex]).contains("-p") {
                            files.append(String(allArgs[filesIndex]))
                            filesIndex += 1
                        }
                        
                        let result = project.copyInto(files)
                        Terminal.log(result.allMessages)
                        if result.success {
                            NotificationCenter.default.post(
                                name: NSNotification.Name(rawValue: "staged-file-updated"),
                                object: nil,
                                userInfo: ["projectName": project.name!]
                            )

                            Terminal.log("Successfully staged files in \(project.name!)")
                        } else {
                            Terminal.log("There was an error.")
                        }
                    } else {
                        Terminal.log("Please provide a list of files using the -f or --files flag")
                    }
                    
                } else {
                    Terminal.log("Project \"\(projectName)\" not found.")
                }
            } else {
                Terminal.log("Please provide a project using the -p or --project flag")
            }
            
        case "commit":
            let message = allArgs.joined(separator: " ")
            Terminal.log(atlasCore.commitChanges(message).allMessages)
        case "clear":
            self.clear()
        case "atlas":
            let atlasCommand = allArgs.removeFirst().lowercased()
            
            switch atlasCommand {
            case "log":
                notificationCenter.post(
                    name: NSNotification.Name(rawValue: "atlas-log"),
                    object: self
                )
            default:
                Terminal.log("Unknown Atlas Command")
            }
        default:
//            notificationCenter.post(
//                name: NSNotification.Name(rawValue: "raw-command"),
//                object: self,
//                userInfo: ["command": fullCommand]
//            )
            let arguments = allArgs.map { String($0) }
            var result = Glue.runProcessError(command, arguments: arguments, currentDirectory: self.atlasCore.appDirectory!)
            if result.count == 0 {
                Terminal.log("\n")
            } else {
                _ = result.removeLast()
                Terminal.log(result)
            }
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
        output.selectAll(self)
        let range = output.selectedRange()
        output.insertText("", replacementRange: range)
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
        let hasFocus = output.isAccessibilityFocused()
        
        guard !queue.isEmpty else {
            return
        }
        
        guard queueTimer == nil else {
            return
        }

        logging = true

        output.isEditable = true

        let text = "\n\n\(self.queue.removeFirst())"
        
        let range = output.selectedRange()
        
        self.output.insertText(text, replacementRange: range)
        
        output.scroll(NSPoint(x: 0, y: output.visibleRect.maxY))
        
        output.isEditable = false
        
        minCursorPosition = (self.output.textStorage?.string ?? "").count
        
        logging = false
        
        if hasFocus {
            let range = output.selectedRange()
            output.setSelectedRange(range)
        }
        
        queueTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: false
        ) { (timer) in
            self.queueTimer = nil
            self.dequeueLog()
        }
    }
}

