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
    
    // Atlas purge -f {files} -p {project}
    
    public var atlasCore: AtlasCore
    
    public let name = "purge"
    public let shortDescription = "Purge (delete) one or more files from an Atlas project commit."
    
    public let filesType = Flag("-f", "--files", description: "Purge these files from the project. Please provide the full GitHub path.")
    public let files = CollectedParameter()
    public let project = Key<String>("-p", "--project", description: "The project you want to purge the files from.")
    
    public init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    public func execute() throws  {
        
    }
}
