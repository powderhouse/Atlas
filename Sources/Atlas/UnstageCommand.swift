//
//  UnstageCommand.swift
//  Atlas
//
//  Created by Jared Cosulich on 2/21/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

public class UnstageCommand: Command {
    
    // Atlas unstage -f {files} -p {project}
    
    public var atlasCore: AtlasCore
    
    public let name = "unstage"
    public let shortDescription = "Unstage files in a project. This will prevent them from being committed until they are staged again."
    
    public let filesType = Flag("-f", "--files", description: "Unstage the specified files.")
    public let files = CollectedParameter()
    public let project = Key<String>("-p", "--project", description: "The project the files reside in.")
    
    public init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    public func execute() throws  {
        if let projectName = project.value {
            if atlasCore.changeState(files.value, within: projectName, to: "unstaged") {
                atlasCore.atlasCommit("Unstaging files in \(projectName)")
            } else {
                print("Faield to unstage files")
            }
        } else {
            print("Please specify a project name with -p or --project (e.g. -p MyProject)")
        }
    }
}
