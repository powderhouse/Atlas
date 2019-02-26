//
//  NoteController.swift
//  atlas
//
//  Created by Jared Cosulich on 12/10/18.
//  Copyright © 2018 Powderhouse Studios. All rights reserved.
//

import Cocoa
import AtlasCore
import Alamofire

struct FilePattern {
    var type: String
    var pattern: String
}

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
        
        let noteText = note.stringValue
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyyMMdd-HHmm"
        let dateString = formatter.string(from: now)

        let filePatterns = [
            FilePattern(type: "Google Document", pattern: "https://docs.google.com/document/d/[^\\s]+/edit"),
            FilePattern(type: "Google Presentation", pattern: "https://docs.google.com/presentation/d/[^\\s]+/edit")
        ]
        
        var fileFound = false
        for filePattern in filePatterns {
            if let regex = try? NSRegularExpression(pattern: filePattern.pattern) {
                let matches = regex.matches(in: noteText, options: [], range: NSRange(location: 0, length: noteText.count))
                let urls = matches.map {
                    return String(noteText[Range($0.range, in: noteText)!])
                }
                for url in urls {
                    fileFound = true
                    Terminal.log("Downloading the \(filePattern.type). This could take a while...")
                    
                    let destination: DownloadRequest.Destination = { tempUrl, response in
                        let filename = response.suggestedFilename ?? "\(filePattern.type)-\(dateString)"
                        let file = self.project!.directory(Project.staged).appendingPathComponent(filename)
                        return (file, [.createIntermediateDirectories, .removePreviousFile])
                    }
                    
                    let postParameters: [String: String] = [
                        "url" : url,
                        "username": "jack"
                    ]
                    AF.download(
                        "https://88in7uss9l.execute-api.us-east-1.amazonaws.com/staging/save",
                        method: .post,
                        parameters: postParameters,
                        encoding: URLEncoding.queryString,
                        to: destination
                    ).downloadProgress(closure: { (progress) in
                        let percent = (progress.fractionCompleted * 100).rounded()
                        Terminal.log("Download Progress: \(percent)%")
                    }).response { response in
                        NotificationCenter.default.post(
                            name: NSNotification.Name(rawValue: "file-updated"),
                            object: nil,
                            userInfo: ["projectName": self.project!.name!]
                        )
                    }
                }
            }
        }
        
        if !fileFound {
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
}
