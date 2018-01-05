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
        let paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        return URL(fileURLWithPath: paths[0]).appendingPathComponent("Atlas/\(atlasDirectory())")
    }
    
    class func createBaseDirectory() {
        createDirectory(baseDirectory())
    }
    
    class func removeBaseDirectory() {
        delete(baseDirectory())
    }
    
    class func fileExists(_ url: URL, isDirectory: Bool=true) -> Bool {
        let fileManager = FileManager.default
        
        var isDir : ObjCBool = (isDirectory ? true : false)
        
        return fileManager.fileExists(atPath: url.path, isDirectory: &isDir)
    }
    
    class func filesInDirectory(_ url: URL) -> [String] {
        let fileManager = FileManager.default
        let contents = try? fileManager.contentsOfDirectory(atPath: url.path)
        
        return contents ?? []
    }
    
    class func createDirectory(_ url: URL) {
        if fileExists(url) {
            return
        }
        
        let fileManager = FileManager.default

        do {
            try fileManager.createDirectory(
                at: url,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            print("Unable to create directory: \(url)")
        }
    }
    
    class func delete(_ url: URL) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: url)
        } catch {}
    }
    
}



