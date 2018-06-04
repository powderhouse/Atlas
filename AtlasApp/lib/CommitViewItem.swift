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
        let attributes = [NSAttributedStringKey.backgroundColor: NSColor.yellow]
        let attrString = NSMutableAttributedString(string: subject.stringValue)

        let text = subject.stringValue
        let lowerText = text.lowercased()
        for term in terms {
            let lowerTerm = term.lowercased()
            var r = Range(text.startIndex..<text.endIndex)
            while let range = lowerText.range(of: lowerTerm, range: r) {
                attrString.setAttributes(attributes, range: NSRange(range, in: text))
                r = Range(range.upperBound..<text.endIndex)
            }
        }
        
        subject.attributedStringValue = attrString
    }
    
}
