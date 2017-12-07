//
//  Testing.swift
//  atlas
//
//  Created by Jared Cosulich on 11/19/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Foundation

class Testing {
    
    class func setup() {
        if let credentials = Git.getCredentials(FileSystem.baseDirectory()) {
            let atlasRepository = FileSystem.baseDirectory().appendingPathComponent(
                "Atlas",
                isDirectory: true
            )
            if FileSystem.fileExists(atlasRepository) {
                if let git = Git(atlasRepository, credentials: credentials) {
                    git.removeGitHub()
                }
            }
        }
        
        FileSystem.removeBaseDirectory()
    }
    
}
