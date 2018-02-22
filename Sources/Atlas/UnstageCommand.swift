//
//  UnstageCommand.swift
//  Atlas
//
//  Created by Jared Cosulich on 2/21/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

class UnstageCommand: Command {
    
    // Atlas unstage -f {files} -p {project}
    
    var atlasCore: AtlasCore
    
    let name = "unstage"
    let shortDescription = "Unstage files in a project. This will prevent them from being committed until they are staged again."
    
    let filesType = Flag("-f", "--files", description: "Unstage the specified files.")
    let imports = CollectedParameter()
    let project = Key<String>("-p", "--project", description: "The project you want to import the files into.")
    
    init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    func execute() throws  {
        if let projectName = project.value {
            for file in imports.value {
                if atlasCore.move(file, into: "unstaged") {
                    if let fileName = file.split(separator: "/").last {
                        print("Unstaged \(fileName) in the project \"\(projectName)\"")
                    }
                }
            }
            atlasCore.atlasCommit("Unstaging files in \(projectName)")
        } else {
            print("Please specify a project name with -p or --project (e.g. -p MyProject)")
        }
    }
}
