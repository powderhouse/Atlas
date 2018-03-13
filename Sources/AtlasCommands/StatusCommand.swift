//
//  StatusCommand.swift
//  Atlas
//
//  Created by Jared Cosulich on 2/16/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

public class StatusCommand: Command {
    
    public var atlasCore: AtlasCore
    
    public let name = "status"
    public let shortDescription = "Get the git status of the local Atlas repository."
    
    public init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    public func execute() throws  {
        if let status = atlasCore.status() {
            print(status)
        } else {
            print("Error getting status. Git likely not yet initialized.")
        }
    }
}


