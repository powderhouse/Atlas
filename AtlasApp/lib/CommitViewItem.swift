//
//  CommitViewItem.swift
//  atlas
//
//  Created by Jared Cosulich on 1/16/18.
//  Copyright © 2018 Powderhouse Studios. All rights reserved.
//

import Cocoa
import AtlasCore

class CommitViewItem: NSCollectionViewItem {

    @IBOutlet weak var project: NSTextField!
    
    @IBOutlet weak var subject: NSTextField!
    
    @IBOutlet var files: NSTextView!
    
    @IBOutlet weak var deleteCommitButton: NSButton!
    
    @IBOutlet var commitController: NSObjectController!

    var commit: Commit? {
        didSet {
            if let commit = self.commit {
                let projectNames: Array<String> = Array(Set(commit.projects.map { $0.name }))
                project.stringValue = projectNames.joined(separator: ", ")
                subject.stringValue = commit.message
                
                if let filesField = files {
                    filesField.isEditable = true
                    filesField.selectAll(self)
                    let range = filesField.selectedRange()
                    filesField.insertText("", replacementRange: range)
                    
                    for file in commit.files {
                        var range = filesField.selectedRange()
                        
                        let link = NSAttributedString(
                            string: file.name,
                            attributes: [NSAttributedStringKey.link: file.url]
                        )
                        
                        filesField.insertText("\n", replacementRange: range)
                        range.location = range.location + 2
                        filesField.insertText(link, replacementRange: range)
                    }
                    
                    filesField.isEditable = false
                }
                
                commitController.addObject(commit)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
    
    @IBAction func deleteCommit(_ sender: NSButton) {
        let a = NSAlert()
        a.messageText = "Remove this commit?"
        a.informativeText = "Are you sure you would like to remove this whole commit?"
        a.addButton(withTitle: "Remove")
        a.addButton(withTitle: "Cancel")
        
        a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                var commitFolders: [String: [String]] = [:]
                if let commit = self.commitController.content as? Commit {
                    for name in commit.projects.map({ $0.name }) {
                        if let projectName = name {
                            if commitFolders[projectName] == nil {
                                commitFolders[projectName] = []
                            }
                            
                            for file in commit.files {
                                let filePath = file.url.replacingOccurrences(
                                    of: ".*/\(projectName)/",
                                    with: "\(projectName)/",
                                    options: [.regularExpression]
                                )
                                let fileComponents = filePath.components(separatedBy: "/")
                                commitFolders[projectName]!.append(fileComponents.dropLast().joined(separator: "/"))
                            }
                        }
                    }
                }
                
                for projectName in commitFolders.keys {
                    if let folders = commitFolders[projectName] {
                        for commitFolder in Array(Set(folders)) {
                            NotificationCenter.default.post(
                                name: NSNotification.Name(rawValue: "remove-file"),
                                object: nil,
                                userInfo: [
                                    "file": commitFolder,
                                    "projectName": projectName
                                ]
                            )
                        }
                    }
                }
            }
        })
    }
    
    func highlight(_ terms: [String]) {
        let subjectText = subject.stringValue
        let lowerSubjectText = subjectText.lowercased()
        
        let filesText = files.textStorage!.string
        let lowerFilesText = filesText.lowercased()
        
        let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.backgroundColor: NSColor.yellow]

        let attrSubject = NSMutableAttributedString(string: subjectText)
        
        for term in terms {
            let lowerTerm = term.lowercased()
            
            var r = Range(uncheckedBounds: (lower: subjectText.startIndex, upper: subjectText.endIndex))
            while let range = lowerSubjectText.range(of: lowerTerm, range: r) {
                attrSubject.setAttributes(attributes, range: NSRange(range, in: subjectText))
                r = Range(uncheckedBounds: (lower: range.upperBound, upper: subjectText.endIndex))
            }

            var r2 = Range(uncheckedBounds: (lower: filesText.startIndex, upper:  filesText.endIndex))
            while let range = lowerFilesText.range(of: lowerTerm, range: r2) {
                let nsRange = NSRange(range, in: filesText)
                files.textStorage?.addAttributes(attributes, range: nsRange)
                r2 = Range(uncheckedBounds: (lower: range.upperBound, upper: filesText.endIndex))
            }
        }
        
        subject.attributedStringValue = attrSubject
    }
    
    func highlightFiles(_ fileNames: [String]) {
        let filesText = files.textStorage!.string
        let attributes = [NSAttributedStringKey.backgroundColor: NSColor.green]
        
        for fileName in fileNames {
            var r = Range(uncheckedBounds: (lower: filesText.startIndex, upper: filesText.endIndex))
            while let range = filesText.range(of: fileName, range: r) {
                files.textStorage?.addAttributes(attributes, range: NSRange(range, in: filesText))
                r = Range(uncheckedBounds: (lower: range.upperBound, upper: filesText.endIndex))
            }
        }
    }
    
}
