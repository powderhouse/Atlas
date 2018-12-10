//
//  NoteController.swift
//  atlas
//
//  Created by Jared Cosulich on 12/10/18.
//  Copyright © 2018 Powderhouse Studios. All rights reserved.
//

import Cocoa
import AtlasCore

class NoteController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var saveButton: NSButton!
    
    @IBOutlet weak var note: NSTextField!
    
    var project: Project?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        note.delegate = self
        note.becomeFirstResponder()
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        saveButton.isEnabled = note.stringValue.count > 0
    }
    
    @IBAction func save(_ sender: NSButton) {
        guard project != nil else { return }
        self.dismiss(self)
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyyMMdd-HHmm"
        let dateString = formatter.string(from: now)
        let filename = "note-\(dateString).md"
        let file = project!.directory(Project.staged).appendingPathComponent(filename)
        project!.createFile(file, message: note.stringValue)
        
        Terminal.log("Note, \(filename), added to \(self.project!.name!)")
        
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: "file-updated"),
            object: nil,
            userInfo: ["projectName": project!.name!]
        )
    }
}
