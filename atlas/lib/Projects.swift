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
    
    let ignore = [
        ".git"
    ]
    
    init(_ atlasRepository: URL) {
        self.atlasRepository = atlasRepository
    }
    
    func create(_ name: String, inDirectory: URL?=nil) -> URL? {
        let directory = (inDirectory ?? atlasRepository)!
        let url = directory.appendingPathComponent(name)
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        
        if fileManager.fileExists(atPath: url.path, isDirectory: &isDir) {
            return url
        }
        
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            
            if fileManager.fileExists(atPath: url.path, isDirectory: &isDir) {
                return url
            }
        } catch {
            print("Caught: \(error)")
        }
        
        return nil
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
