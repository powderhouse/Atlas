//
//  LogoutCommand.swift
//  AtlasPackageDescription
//
//  Created by Jared Cosulich on 2/13/18.
//

import Cocoa
import SwiftCLI

class LogoutCommand: Command {
    
    let name = "logout"
    let shortDescription = "Log out of Atlas."
    
    func execute() throws  {
        print("LOGOUT")
    }
    
}

