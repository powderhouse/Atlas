//
//  LogCommand.swift
//  AtlasPackageDescription
//
//  Created by Jared Cosulich on 3/9/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

public class LogCommand: Command {
    
    public var atlasCore: AtlasCore
    
    public let name = "log"
    public let shortDescription = "Show all commits into Atlas or a specific project."
    public let project = Key<String>("-p", "--project", description: "The project you want to import the files into.")

    public init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    public func execute() throws  {
        let log = atlasCore.log(projectName: project.value)
    
        for commit in log {
            print("")
            print(commit.message)
            
            for file in commit.files {
                print("-- \(file.name) -> \(file.url)")
            }
        }
    }
}
