//
//  LoginCommand.swift
//  AtlasPackageDescription
//
//  Created by Jared Cosulich on 2/13/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

class LoginCommand: Command {
    
    var atlasCore: AtlasCore
    
    let name = "login"
    let shortDescription = "Login to Atlas using your GitHub credentials."
    
    let usernameOption = Key<String>("-u", "--username", description: "Your GitHub username")
    let passwordOption = Key<String>("-p", "--password", description: "Your GitHub password")
    
    init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    func execute() throws  {
        var username = usernameOption.value
        if username == nil {
            username = Input.awaitInput(message: "GitHub Username:")
        }

        var password = passwordOption.value
        if password == nil {
            password = Input.awaitInput(message: "GitHub Password:", secure: true)
        }
        
        guard username != nil else {
            print("Please provide a username using -u or --username (e.g. -u github_username)")
            return
        }

        guard password != nil else {
            print("Please provide a username using -p or --password (e.g. -p github_password)")
            return
        }

        print("Logged in as \(username)/\(password): \(atlasCore.hello())")
    }
    
}
