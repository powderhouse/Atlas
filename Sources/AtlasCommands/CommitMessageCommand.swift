//
//  CommitMessageCommand.swift
//  Atlas
//
//  Created by Jared Cosulich on 3/13/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

public class CommitMessageCommand: Command {
    
    // Atlas commit_message -m {message} -p {project}
    
    public var atlasCore: AtlasCore
    
    public let name = "commit_message"
    public let shortDescription = "Save a commit message for this project."
    
    public let message = Key<String>("-m", "--message", description: "The commit message.")
    public let project = Key<String>("-p", "--project", description: "The project the files reside in.")
    
    public init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    public func execute() throws  {
        if let projectName = project.value {
            if let project = atlasCore.project(projectName) {
                if let message = message.value {
                    if (project.commitMessage(message)) {
                        print("Commit message saved to \(projectName)")
                    } else {
                        print("Failed to save commit message.")
                    }
                } else {
                    print("Please provide a commit message.")
                }
            } else {
                print("Failed to locate or initialize project")
            }
        } else {
            print("Please specify a project name with -p or --project (e.g. -p MyProject)")
        }
    }
}


