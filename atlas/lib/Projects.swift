//
//  Projects.swift
//  atlas
//
//  Created by Jared Cosulich on 12/6/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Foundation

class Projects {
    
    let atlasRepository: URL!
    let git: Git?
    
    var cache: [Project] = []
    var active: Project?
    
    let ignore = [
        ".git"
    ]
    
    init(_ atlasRepository: URL, git: Git?=nil) {
        self.atlasRepository = atlasRepository
        self.git = git
        
        for name in names() {
            cache.append(buildProject(name))
        }
    }
    
    func buildProject(_ name: String) -> Project {
        return Project(directory(name))        
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
            Terminal.log("Create Project: \(name)")
            
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
    
    func names() -> [String] {
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
    
    func list() -> [Project] {
        let projectNames = names()
        for i in 0..<projectNames.count {
            if cache.count <= i {
                cache.append(buildProject(projectNames[i]))
            } else if cache[i].name != projectNames[i] {
                cache[i] = buildProject(projectNames[i])
            }
        }
        return cache
    }
    
    func directory(_ name: String) -> URL {
        return atlasRepository.appendingPathComponent(name)
    }
    
    func setActive(_ name: String) {
        self.active = list().filter { $0.name == name }.first
    }
}
