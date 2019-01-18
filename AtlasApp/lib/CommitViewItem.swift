//
//  CommitViewItem.swift
//  atlas
//
//  Created by Jared Cosulich on 1/16/18.
//  Copyright © 2018 Powderhouse Studios. All rights reserved.
//

import Cocoa
import AtlasCore
import QuickLook

class CommitViewItem: NSCollectionViewItem, NSCollectionViewDelegate, NSCollectionViewDataSource {
    
    let bufferDim = CGFloat(10)
    let fileHeight = CGFloat(30)
    
    @IBOutlet weak var project: NSTextField!
    
    @IBOutlet weak var subject: NSTextField!
    
    @IBOutlet weak var filesScrollView: NSScrollView!
    @IBOutlet weak var filesClipView: NSClipView!
    @IBOutlet weak var files: NSCollectionView!
    
    @IBOutlet weak var deleteCommitButton: NSButton!
    
    @IBOutlet var commitController: NSObjectController!

    var deleting = false
    var countedFiles: [File] = []
    var commit: Commit? {
        didSet {
            if let commit = self.commit {
                let projectNames: Array<String> = Array(Set(commit.projects.map { $0.name }))
                project.stringValue = projectNames.joined(separator: ", ")
                subject.stringValue = commit.message
                
                commitController.addObject(commit)
            }
            files.reloadData()
        }
    }
    var images: [String: NSImage] = [:] {
        didSet {
            DispatchQueue.main.async(execute: {
                for (index, file) in self.countedFiles.enumerated() {
                    if oldValue[file.url] != self.images[file.url] {
                        if let commitFileViewItem = self.files.item(at: index) {
                            commitFileViewItem.imageView?.image = self.images[file.url]
                        }
                    }
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        view.layer?.borderColor = NSColor.gray.cgColor
        view.layer?.borderWidth = 1
        
        files.delegate = self
        files.dataSource = self

        configureFiles()
    }
    
    override func prepareForReuse() {
        commit = nil
        super.prepareForReuse()
    }
    
    func configureFiles() {
        files.isSelectable = false
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: CGFloat(files.frame.width), height: fileHeight)
        flowLayout.minimumLineSpacing = 10
        files.collectionViewLayout = flowLayout
        
        view.wantsLayer = true
    }
    
    func setFrameSize() {
        DispatchQueue.main.async(execute: {
            self.files.setFrameSize(
                NSSize(
                    width: self.view.frame.width,
                    height: CGFloat(self.countedFiles.count) * (self.fileHeight + (self.bufferDim * CGFloat(2)))
                )
            )
        })
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if let commit = self.commit {
            countedFiles = commit.files
            return countedFiles.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {

        let item = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CommitFileViewItem"),
            for: indexPath
        )

        guard let commitFileViewItem = item as? CommitFileViewItem else {
            return item
        }

        let file = countedFiles[indexPath.item]
        commitFileViewItem.identifier = NSUserInterfaceItemIdentifier(file.name)
        commitFileViewItem.project = commit?.projects.first
        commitFileViewItem.fileLink.title = file.name
        commitFileViewItem.url = URL(string: file.url)

        let thumbnailFormats = ["png", "jpg", "jpeg", "pdf", "gif"]
        if thumbnailFormats.contains(file.url.components(separatedBy: ".").last ?? "xxx") {
            if let image = images[file.url] {
                commitFileViewItem.imageView?.image = image
            }
        }

        return commitFileViewItem
    }
        
    func filePath(_ url: String, projectName: String) -> String {
        return url.replacingOccurrences(
            of: ".*/\(projectName)/",
            with: "\(projectName)/",
            options: [.regularExpression]
        )
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
                            
                            for file in commit.files where file.url.contains("\(projectName)/") {
                                let path = self.filePath(file.url, projectName: projectName)
                                let fileComponents = path.components(separatedBy: "/")
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
                                    "file": "\(commitFolder)/",
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
//        let subjectText = subject.stringValue
//        let lowerSubjectText = subjectText.lowercased()
//
//        let filesText = files.textStorage!.string
//        let lowerFilesText = filesText.lowercased()
//
//        let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.backgroundColor: NSColor.yellow]
//
//        let attrSubject = NSMutableAttributedString(string: subjectText)
//
//        for term in terms {
//            let lowerTerm = term.lowercased()
//
//            var r = Range(uncheckedBounds: (lower: subjectText.startIndex, upper: subjectText.endIndex))
//            while let range = lowerSubjectText.range(of: lowerTerm, range: r) {
//                attrSubject.setAttributes(attributes, range: NSRange(range, in: subjectText))
//                r = Range(uncheckedBounds: (lower: range.upperBound, upper: subjectText.endIndex))
//            }
//
//            var r2 = Range(uncheckedBounds: (lower: filesText.startIndex, upper:  filesText.endIndex))
//            while let range = lowerFilesText.range(of: lowerTerm, range: r2) {
//                let nsRange = NSRange(range, in: filesText)
//                files.textStorage?.addAttributes(attributes, range: nsRange)
//                r2 = Range(uncheckedBounds: (lower: range.upperBound, upper: filesText.endIndex))
//            }
//        }
//
//        subject.attributedStringValue = attrSubject
    }

    func highlightFiles(_ fileNames: [String]) {
//        let filesText = files.textStorage!.string
//        let attributes = [NSAttributedStringKey.backgroundColor: NSColor.green]
//
//        for fileName in fileNames {
//            var r = Range(uncheckedBounds: (lower: filesText.startIndex, upper: filesText.endIndex))
//            while let range = filesText.range(of: fileName, range: r) {
//                files.textStorage?.addAttributes(attributes, range: NSRange(range, in: filesText))
//                r = Range(uncheckedBounds: (lower: range.upperBound, upper: filesText.endIndex))
//            }
//        }
    }
    
}
