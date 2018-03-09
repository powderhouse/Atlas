//
//  LogCommand.swift
//  AtlasPackageDescription
//
//  Created by Jared Cosulich on 3/9/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

class LogCommand: Command {
    
    var atlasCore: AtlasCore
    
    let name = "log"
    let shortDescription = "Show all commits into Atlas or a specific project."
    let project = Key<String>("-p", "--project", description: "The project you want to import the files into.")

    init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    func execute() throws  {
        let log = atlasCore.log(project.value)
    
        for commit in log {
            print("")
            print(commit.message)
            
            for file in commit.files {
                print("-- \(file.name) -> \(file.url)")
            }
        }
    }
}
