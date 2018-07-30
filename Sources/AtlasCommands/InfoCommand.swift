//
//  InfoCommand.swift
//  Atlas
//
//  Created by Jared Cosulich on 2/14/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

public class InfoCommand: Command {
    
    public var atlasCore: AtlasCore
    
    public let name = "info"
    public let shortDescription = "Login information regarding Atlas."
    
    public init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    public func execute() throws  {
        if let credentials = atlasCore.getCredentials() {
            print("Logged into Atlas as \(credentials.username)")
            if let repository = atlasCore.gitHubRepository() {
                print("GitHub Repository: \(repository)")
            }
            if let localRepository = atlasCore.appDirectory {
                print("Local repository: \(localRepository.path)")
            }
        } else {
            print("Not logged in.")
        }
    }
}

