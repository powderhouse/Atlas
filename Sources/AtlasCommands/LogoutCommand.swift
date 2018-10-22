//
//  LogoutCommand.swift
//  AtlasPackageDescription
//
//  Created by Jared Cosulich on 2/13/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

public class LogoutCommand: Command {
    
    public var atlasCore: AtlasCore
    
    public let name = "logout"
    public let shortDescription = "Log out of Atlas."
    
    public init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    public func execute() throws  {
        print(atlasCore.deleteCredentials().allMessages)
        print("You have been logged out of Atlas.")
    }
    
}

