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
        return URL(fileURLWithPath: paths[0]).appendingPathComponent(atlasDirectory())
    }
    
    class func removeBaseDirectory() {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: baseDirectory())
        } catch {}
    }
    
    class func createDirectory(_ name: String) -> Bool {
        let url = baseDirectory().appendingPathComponent(name)
        let fileManager = FileManager.default
        var isDir : ObjCBool = false

        if fileManager.fileExists(
                atPath: url.path,
                isDirectory: &isDir
            ) {
            return true
        }
        
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)

            return fileManager.fileExists(
                atPath: url.path,
                isDirectory: &isDir
            )
        } catch {
            print("Caught: \(error)")
            return false
        }
    }
    
    class func createAccount(_ email: String) -> Bool {
        return FileSystem.createDirectory(email)
    }
    
    class func account() -> String? {
        let fileManager = FileManager.default
        let contents = try? fileManager.contentsOfDirectory(atPath: baseDirectory().path)
       
        if contents == nil || contents!.count == 0 {
            return nil
        } else {
            return contents![0]
        }
    }
}


