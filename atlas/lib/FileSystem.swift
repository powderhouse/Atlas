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
        createDirectory(baseDirectory())
    }
    
    class func removeBaseDirectory() {
        removeDirectory(baseDirectory())
    }
    
    class func createDirectory(_ url: URL) {
        let fileManager = FileManager.default
        
        var isDir : ObjCBool = true
        
        if fileManager.fileExists(atPath: url.path, isDirectory: &isDir) {
            return
        }
        
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
    
    class func removeDirectory(_ url: URL) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: url)
        } catch {}
    }
    
}



