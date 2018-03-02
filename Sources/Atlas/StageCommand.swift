//
//  StageCommand.swift
//  Atlas
//
//  Created by Jared Cosulich on 2/26/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

class StageCommand: Command {
    
    // Atlas stage -f {files} -p {project}
    
    var atlasCore: AtlasCore
    
    let name = "stage"
    let shortDescription = "Stage files in a project, moving them from the unstaged state to the staged state."
    
    let filesType = Flag("-f", "--files", description: "Stage the specified files.")
    let files = CollectedParameter()
    let project = Key<String>("-p", "--project", description: "The project the files reside in.")
    
    init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    func execute() throws  {
        if let projectName = project.value {
            if atlasCore.changeState(files.value, within: projectName, to: "staged") {
                atlasCore.atlasCommit("Staging files in \(projectName)")
            } else {
                print("Faield to stage files")
            }
        } else {
            print("Please specify a project name with -p or --project (e.g. -p MyProject)")
        }
    }
}

