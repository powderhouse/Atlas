//
//  FileSystem.swift
//  atlas
//
//  Created by Jared Cosulich on 11/16/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Foundation

class FileSystem {
    
    class func atlasDirectory() -> String {
        return Configuration.atlasDirectory
    }
    
    class func baseDirectory() -> URL {
        let paths = NSSearchPathForDirectoriesInDomains(.applicationDirectory, .userDomainMask, true)
        return URL(fileURLWithPath: paths[0]).appendingPathComponent("Atlas/\(atlasDirectory())")
    }
    
    class func createBaseDirectory() {
        let fileManager = FileManager.default
        
        var isDir : ObjCBool = true
        
        if fileManager.fileExists(atPath: baseDirectory().path, isDirectory: &isDir) {
            return
        }
        
        do {
            try fileManager.createDirectory(
                at: baseDirectory(),
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            print("Unable to create baseDirectory: \(baseDirectory())")
        }
    }
    
    class func removeBaseDirectory() {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: baseDirectory())
        } catch {}
    }
    
    class func createDirectory(_ name: String, inDirectory: URL=baseDirectory()) -> URL? {
        let url = inDirectory.appendingPathComponent(name)
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
    
    class func projects() -> [String] {
        let fileManager = FileManager.default
        let contents = try? fileManager.contentsOfDirectory(
            at: baseDirectory(),
            includingPropertiesForKeys: [URLResourceKey.isDirectoryKey]
        )
        
        guard contents != nil else {
            return []
        }
        
        let subdirectories = contents!.filter { $0.hasDirectoryPath }
        
        return subdirectories.map { $0.lastPathComponent }.sorted()
    }
    
}



