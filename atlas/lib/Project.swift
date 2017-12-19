//
//  Project.swift
//  atlas
//
//  Created by Jared Cosulich on 12/12/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Foundation

class Project {
    let directory: URL!
    let staging: URL!
    var name: String!
    var files: [String]!
    var stagedFiles: [String]!
    
    let ignore = [
        "readme.md",
        "staging"
    ]
    
    init(_ directory: URL) {
        self.directory = directory
        self.name = directory.lastPathComponent
        self.staging = directory.appendingPathComponent("staging")
        
        self.files = getFiles()
        self.stagedFiles = getFiles(staging)
    }
    
    func stageFile(_ url: URL) {
        guard directory != nil else { return }
        _ = Glue.runProcess("cp", arguments: [url.path, staging.path])
        self.stagedFiles = getFiles(staging)
        
        if let projectName = name {
            Terminal.log("\"\(url.lastPathComponent)\" staged in \"\(projectName)\"")
        }
        
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: "project-staged-files"),
            object: self
        )
    }
    
    func getFiles(_ url: URL?=nil) -> [String] {
        let inDirectory = (url ?? directory)!
        let fileManager = FileManager.default
        
        let contents = try? fileManager.contentsOfDirectory(
            at: inDirectory,
            includingPropertiesForKeys: [URLResourceKey.isDirectoryKey]
        )
        
        guard contents != nil else {
            return []
        }
        
        let filteredContents = contents!.filter { !ignore.contains($0.lastPathComponent) }
        return filteredContents.map { $0.lastPathComponent }.sorted()
    }
}
