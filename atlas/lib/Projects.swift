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
    
    let ignore = [
        ".git"
    ]
    
    init(_ atlasRepository: URL, git: Git?=nil) {
        self.atlasRepository = atlasRepository
        self.git = git
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
            
            _ = git?.add()
            _ = git?.commit()
            _ = git?.pushToGitHub()
        }
        
        return url
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

    
}
