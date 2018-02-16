//
//  InfoCommand.swift
//  Atlas
//
//  Created by Jared Cosulich on 2/14/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

class InfoCommand: Command {
    
    var atlasCore: AtlasCore
    
    let name = "info"
    let shortDescription = "Login information regarding Atlas."
    
    init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    func execute() throws  {
        if let credentials = atlasCore.getGitCredentials() {
            print("Logged into Atlas as \(credentials.username)")
            if let repository = atlasCore.gitHubRepository() {
                print("GitHub Repository: \(repository)")
            }
            print("Local repository: \(atlasCore.baseDirectory.path)")
        }
    }
}

