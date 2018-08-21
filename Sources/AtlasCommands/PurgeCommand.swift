//
//  PurgeCommand.swift
//  AtlasCommands
//
//  Created by Jared Cosulich on 3/16/18.
//

// git filter-branch --force --index-filter ‘git rm --cached --ignore-unmatch PATH_TO_FILE’ --prune-empty --tag-name-filter cat -- --all && git for-each-ref --format=‘delete %(refname)’ refs/original | git update-ref --stdin && git reflog expire --expire=now --all && git gc --prune=now

import Cocoa
import SwiftCLI
import AtlasCore

public class PurgeCommand: Command {
    
    // Atlas purge {files}
    
    public var atlasCore: AtlasCore
    
    public let name = "purge"
    public let shortDescription = "Purge (delete) one or more files from an Atlas project commit."
    
    public let files = CollectedParameter()
    
    public init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    public func execute() throws  {
        let result = atlasCore.purge(files.value)
        if result.success {
            print("Files successfully purged.")
        } else {
            print(result.allMessages)
            print("There was an error purging these files: \(files.value)")
        }
    }
}
