//
//  FileSystem.swift
//  atlas
//
//  Created by Jared Cosulich on 11/16/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Foundation

class FileSystem {
    
    class func applicationDataDirectory() -> URL {
        let sharedFM = FileManager.default
        let possibleURLs = sharedFM.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        var appSupportDir: URL? = nil
        var appDirectory: URL? = nil

        if possibleURLs.count >= 1 {
            // Use the first directory (if multiple are returned)
            appSupportDir = possibleURLs[0]
        }
        
        // If a valid app support directory exists, add the
        // app's bundle ID to it to specify the final directory.
        if appSupportDir != nil {
            let appBundleID: String? = Bundle.main.bundleIdentifier
            appDirectory = appSupportDir?.appendingPathComponent(appBundleID ?? "")
        }
        return appDirectory!
    }

    class func baseDirectory() -> URL {
        let paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        return URL(fileURLWithPath: paths[0])
    }
    
    class func createDirectory(_ name: String) -> Bool {
        let url = baseDirectory().appendingPathComponent(name)
        let fileManager = FileManager.default
        
//        if fileManager.fileExists(
//                atPath: url.path,
//                isDirectory: &isDir
//            ) {
//            return true
//        }
        
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)

            var isDir : ObjCBool = false
            return fileManager.fileExists(
                atPath: url.path,
                isDirectory: &isDir
            )
        } catch {
            print("Caught: \(error)")
            return false
        }
    }
}


