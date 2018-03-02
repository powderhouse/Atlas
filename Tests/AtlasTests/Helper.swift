//
//  Helper.swift
//  AtlasCore
//
//  Created by Jared Cosulich on 2/13/18.
//

import Cocoa
import AtlasCore

class Helper {
    
    class func addFile(_ name: String, directory: URL) -> URL {
        let filePath = "\(directory.path)/\(name)"
        _ = Glue.runProcess("touch", arguments: [filePath])
        return URL(fileURLWithPath: filePath)
    }
    
    class func initAtlasCore(_ atlasCore: AtlasCore) -> Bool {
        let username = "atlastest"
        let password = "1a2b3c4d"
        
        let credentials = Credentials(username, password: password)
        if atlasCore.initGitAndGitHub(credentials) {
            _ = atlasCore.initProject("General")
            atlasCore.atlasCommit("Atlas Initialization")
        } else {
            return false
        }
        return true
    }
}

