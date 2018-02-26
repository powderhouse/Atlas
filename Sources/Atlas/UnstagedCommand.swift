//
//  UnstagedCommand.swift
//  Atlas
//
//  Created by Jared Cosulich on 2/26/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

class UnstagedCommand: Command {
    
    // Atlas unstaged -p {project}
    
    var atlasCore: AtlasCore
    
    let name = "unstaged"
    let shortDescription = "List out all unstaged files in a project."
    
    let project = Key<String>("-p", "--project", description: "The project name.")
    
    init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    func execute() throws  {
        if let projectName = project.value {
            if let project = atlasCore.project(projectName) {
                print("Unstaged Files in \(projectName)")
                for file in project.files("unstaged") {
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


