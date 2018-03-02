//
//  StagedCommand.swift
//  Atlas
//
//  Created by Jared Cosulich on 2/26/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

class StagedCommand: Command {
    
    // Atlas staged -p {project}
    
    var atlasCore: AtlasCore
    
    let name = "staged"
    let shortDescription = "List out all staged files in a project."
    
    let project = Key<String>("-p", "--project", description: "The project name.")
    
    init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    func execute() throws  {
        if let projectName = project.value {
            if let project = atlasCore.project(projectName) {
                print("Staged Files in \(projectName)")
                for file in project.files("staged") {
                    print(file)
                }
            } else {
                print("No project found with the name \(projectName)")
            }
        } else {
            print("Please specify a project name with -p or --project (e.g. -p MyProject)")
        }
    }
}

