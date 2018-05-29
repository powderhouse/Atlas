//
//  AtlasVersionCommand.swift
//  AtlasAppUITests
//
//  Created by Jared Cosulich on 5/28/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

public class AtlasVersionCommand: Command {
    
    public var atlasCore: AtlasCore
    public var version: String
    
    public let name = "version"
    public let shortDescription = "The current version of this app, including the version of AtlasCore."
    
    public init(_ atlasCore: AtlasCore, version: String) {
        self.atlasCore = atlasCore
        self.version = version
    }
    
    public func execute() throws  {
        print("Atlas CLI: \(version)  --  AtlasCore: \(AtlasCore.version)")
    }
}
