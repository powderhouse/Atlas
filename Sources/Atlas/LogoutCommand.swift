//
//  LogoutCommand.swift
//  AtlasPackageDescription
//
//  Created by Jared Cosulich on 2/13/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

class LogoutCommand: Command {
    
    var atlasCore: AtlasCore
    
    let name = "logout"
    let shortDescription = "Log out of Atlas."
    
    init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    func execute() throws  {
        atlasCore.deleteCredentials()        
        print("You have been logged out of Atlas.")
    }
    
}

