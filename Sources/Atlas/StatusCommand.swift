//
//  StatusCommand.swift
//  Atlas
//
//  Created by Jared Cosulich on 2/16/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

class StatusCommand: Command {
    
    var atlasCore: AtlasCore
    
    let name = "status"
    let shortDescription = "Get the git status of the local Atlas repository."
    
    init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    func execute() throws  {
        if let status = atlasCore.status() {
            print(status)
        } else {
            print("Error getting status. Git likely not yet initialized.")
        }
    }
}


