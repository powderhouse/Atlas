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
    var active = true
    
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
        
        if let scrollSize = output.enclosingScrollView?.contentSize {
            output.frame = CGRect(x: 0, y: 0, width: scrollSize.width, height: 0)
            output.textContainer!.containerSize = CGSize(width: scrollSize.width, height: CGFloat.greatestFiniteMagnitude)
            output.textContainer!.widthTracksTextView = true
        }
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
    
    func activate() {
        active = true
        
        let messages = queue.joined(separator: "\n\n")
        queue = []
        writeOutput(NSAttributedString(string: messages))
        
        scrollToEnd()
    }
    
    func deactivate() {
        active = false
    }
    
    func runCommand(_ fullCommand: String) {
        var allArgs = fullCommand.components(separatedBy: " ")
        
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
            Terminal.log(atlasCore.commitChanges().allMessages)
        case "clear":
            self.clear()
        case "s3":
            Terminal.log("Files synced with S3: \(atlasCore.filesSyncedWithAnnex())")
        case "s3files":
            let missing = atlasCore.missingFilesBetweenLocalAndS3()
            if missing["remote"]?.count ?? 0 > 0 {
                Terminal.log("Files missing from S3:\n\(missing["remote"]!.joined(separator: "\n"))")
            }
            if missing["local"]?.count ?? 0 > 0 {
                Terminal.log("Files missing from local:\n\(missing["local"]!.joined(separator: "\n"))")
            }
            if missing["remote"]?.count ?? 0 == 0 && missing["local"]?.count ?? 0 == 0 {
                Terminal.log("All files are synced")
            }
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
        output.selectAll(self)
        let range = output.selectedRange()
        output.insertText("", replacementRange: range)
    }
    
    func scrollToEnd() {
        output.scrollToEndOfDocument(nil)
    }
    
    class func log(_ text: String) {
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: "log"),
            object: nil,
            userInfo: ["text": text]
        )
    }
    
    @objc func log(notification: Notification) {
        DispatchQueue.global().async(execute: {
            DispatchQueue.main.sync(execute: {
                if let text = notification.userInfo?["text"] as? String {
                    self.queue.append(text)
                }
        
                 self.dequeueLog()
            })
        })
    }
    
    private func dequeueLog() {
        objc_sync_enter(self.queue)
        if active && !logging && queueTimer == nil {
            logging = true

            let hasFocus = output.isAccessibilityFocused()
        
            if let item = self.queue.first {
                if self.queue.count == 1 {
                    self.queue = []
                } else {
                    self.queue.removeFirst()
                }
        
                let text = NSAttributedString(string: "\n\n\(item)")
        
                writeOutput(text)
        
                NotificationCenter.default.post(
                    name: NSNotification.Name(rawValue: "sync"),
                    object: nil
                )
        
                if hasFocus {
                    let range = output.selectedRange()
                    output.setSelectedRange(range)
                }
                
                queueTimer = Timer.scheduledTimer(
                    withTimeInterval: 0.01,
                    repeats: false
                ) { (timer) in
                    self.queueTimer = nil
                    DispatchQueue.main.async(execute: {
                        self.dequeueLog()
                    })
                }
            }
            logging = false
        }
        objc_sync_exit(self.queue)
    }
    
    private func writeOutput(_ text: NSAttributedString) {
        let shouldScroll = (NSMaxY(self.output.visibleRect) >= NSMaxY(self.output.bounds) - 30)
        
        self.output.textStorage?.append(text)
        
        if shouldScroll {
            scrollToEnd()
        }
    }
}

