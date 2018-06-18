//
//  CommitViewItem.swift
//  atlas
//
//  Created by Jared Cosulich on 1/16/18.
//  Copyright © 2018 Powderhouse Studios. All rights reserved.
//

import Cocoa

class CommitViewItem: NSCollectionViewItem {

    @IBOutlet weak var project: NSTextField!
    
    @IBOutlet weak var subject: NSTextField!
    
    @IBOutlet var files: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
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
