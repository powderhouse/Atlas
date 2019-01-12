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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
        filesScrollView.backgroundColor = NSColor.lightGray
        filesClipView.backgroundColor = NSColor.lightGray
        
        files.delegate = self
        files.dataSource = self

        configureFiles()
    }
    
    func configureFiles() {
        files.isSelectable = false
        // Can't figure out why NSCollectionViewFlowLayout is causing errors so using GridLayout
        let flowLayout = NSCollectionViewGridLayout()
        
        flowLayout.minimumItemSize = NSSize(width: CGFloat(files.frame.width - 20), height: fileHeight)
        flowLayout.maximumItemSize = NSSize(width: CGFloat(files.frame.width - 20), height: fileHeight)
        flowLayout.maximumNumberOfColumns = 1
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        files.collectionViewLayout = flowLayout

        files.wantsLayer = true
        setFrameSize()
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
//        commitFileViewItem.url = URL(string: file.url)
        commitFileViewItem.url = URL(string: "https://images.pexels.com/photos/67636/rose-blue-flower-rose-blooms-67636.jpeg")
        

        var image: NSImage? = nil
        let imageUrl = "https://upload.wikimedia.org/wikipedia/commons/a/a3/Eq_it-na_pizza-margherita_sep2005_sml.jpg"
        if let url = URL(string: imageUrl) {
            if let data = try? Data(contentsOf: url) {
                image = NSImage(data: data)
            }
        }
        image?.size = NSSize(width: 30, height: 30)
        
//        let image = NSWorkspace.shared.icon(forFile: "/Users/jcosulich/⁨workspace/⁨personal/⁨movies/The.Post.2017.DVDScr.XVID.AC3.HQ.Hive-CM8.mp4")
        commitFileViewItem.image.image = image
        
        return commitFileViewItem
    }
    
//    func textView(_ textView: NSTextView, clickedOnLink link: Any, at charIndex: Int) -> Bool {
//        if let purgeUrl = link as? String {
//            guard purgeUrl.starts(with: "purge:") else {
//                return false
//            }
//
//            let url = purgeUrl.replacingOccurrences(of: "purge:", with: "")
//
//            if let commit = self.commitController.content as? Commit {
//                for name in commit.projects.map({ $0.name }) {
//                    if let projectName = name {
//                        if url.contains(substring: projectName) {
//                            let a = NSAlert()
//                            a.messageText = "Remove this file?"
//                            let fileName = url.components(separatedBy: "/").last
//                            a.informativeText = "Are you sure you would like to remove the file, \(fileName ?? ""), from this commit?"
//                            a.addButton(withTitle: "Remove")
//                            a.addButton(withTitle: "Cancel")
//
//                            a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
//                                if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
//                                    NotificationCenter.default.post(
//                                        name: NSNotification.Name(rawValue: "remove-file"),
//                                        object: nil,
//                                        userInfo: [
//                                            "file": self.filePath(url, projectName: projectName),
//                                            "projectName": projectName
//                                        ]
//                                    )
//                                }
//                            })
//
//                            return true
//                        }
//                    }
//                }
//            }
//        }
//        return false
//    }
    
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
