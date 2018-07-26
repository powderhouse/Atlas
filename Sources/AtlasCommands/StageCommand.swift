//
//  StageCommand.swift
//  Atlas
//
//  Created by Jared Cosulich on 2/26/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

public class StageCommand: Command {
    
    // Atlas stage -f {files} -p {project}
    
    public var atlasCore: AtlasCore
    
    public let name = "stage"
    public let shortDescription = "Stage files in a project, moving them from the unstaged state to the staged state."
    
    public let filesType = Flag("-f", "--files", description: "Stage the specified files.")
    public let files = CollectedParameter()
    public let projectInput = Key<String>("-p", "--project", description: "The project the files reside in.")
    
    public init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    public func execute() throws  {
        if let projectName = projectInput.value {
            if let project = atlasCore.project(projectName) {
                if project.changeState(files.value, to: "staged") {
                    atlasCore.atlasCommit("Staging files in \(projectName)")
                } else {
                    print("Failed to stage files")
                }
            }
        } else {
            print("Please specify a project name with -p or --project (e.g. -p MyProject)")
        }
    }
}

