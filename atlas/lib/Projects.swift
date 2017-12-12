//
//  Projects.swift
//  atlas
//
//  Created by Jared Cosulich on 12/6/17.
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
    
    func stageFile(_ path: String) {
        guard directory != nil else { return }
        _ = Glue.runProcess("cp", arguments: [path, staging.path])
        self.stagedFiles = getFiles(staging)
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

class Projects {
    
    let atlasRepository: URL!
    let git: Git?
    
    
    var active: Project? {
        didSet {
            
        }
    }
    
    let ignore = [
        ".git"
    ]
    
    init(_ atlasRepository: URL, git: Git?=nil) {
        self.atlasRepository = atlasRepository
        self.git = git
        
    }
    
    func commitChanges() {
        _ = git?.add()
        _ = git?.commit()
        _ = git?.pushToGitHub()
    }
    
    func create(_ name: String, inDirectory: URL?=nil) -> URL? {
        let directory = (inDirectory ?? atlasRepository)!
        let url = directory.appendingPathComponent(name)
        let fileManager = FileManager.default
        var isDir : ObjCBool = true
        
        if !fileManager.fileExists(atPath: url.path, isDirectory: &isDir) {
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Caught: \(error)")
                return nil
            }
        }
        
        let readme = url.appendingPathComponent("readme.md")
        if !FileSystem.fileExists(readme, isDirectory: false) {
            do {
                try "This is your \(name) project".write(to: readme, atomically: true, encoding: .utf8)
            } catch {
                print("Caught: \(error)")
                return nil
            }
        }
        
        createStaging(url)
        
        commitChanges()
        
        return url
    }
    
    func createStaging(_ projectDirectory: URL) {
        let url = projectDirectory.appendingPathComponent("staging")
        let fileManager = FileManager.default
        var isDir : ObjCBool = true
        
        if !fileManager.fileExists(atPath: url.path, isDirectory: &isDir) {
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Caught: \(error)")
            }
        }
        
        let readme = url.appendingPathComponent("readme.md")
        if !FileSystem.fileExists(readme, isDirectory: false) {
            do {
                try "This is the staging directory for this project".write(to: readme, atomically: true, encoding: .utf8)
            } catch {
                print("Caught: \(error)")
            }            
        }
    }
    
    func list() -> [String] {
        let fileManager = FileManager.default
        let contents = try? fileManager.contentsOfDirectory(
            at: atlasRepository,
            includingPropertiesForKeys: [URLResourceKey.isDirectoryKey]
        )
        
        guard contents != nil else {
            return []
        }
        
        let subdirectories = contents!.filter {
            $0.hasDirectoryPath && !ignore.contains($0.lastPathComponent)            
        }
        
        return subdirectories.map { $0.lastPathComponent }.sorted()
    }
    
    func directory(_ name: String) -> URL {
        return atlasRepository.appendingPathComponent(name)
    }
    
    func setActive(_ name: String) {
        let projectDirectory = directory(name)
        self.active = Project(projectDirectory)
    }
}
