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
        return URL(fileURLWithPath: paths[0]).appendingPathComponent(atlasDirectory())
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
    
    class func createAccount(_ email: String) -> Bool {
        return FileSystem.createDirectory(email) != nil
    }
    
    class func account() -> String? {
        let fileManager = FileManager.default
        let baseDirectoryPath = baseDirectory().path
        let contents = try? fileManager.contentsOfDirectory(atPath: baseDirectoryPath)
       
        if contents == nil || contents!.count == 0 {
            return nil
        } else {
            return contents![0]
        }
    }
    
    class func projects() -> [String] {
        if let account = account() {
            let fileManager = FileManager.default
            let accountDirectory = baseDirectory().appendingPathComponent(account)
            let contents = try? fileManager.contentsOfDirectory(atPath: accountDirectory.path)
            if contents == nil {
                return []
            } else {
                return contents!
            }
        }

        return []
    }
    
    class func accountDirectory() -> URL? {
        if let accountFolder = account() {
            return baseDirectory().appendingPathComponent(accountFolder)
        }
        return nil
    }
    
}


