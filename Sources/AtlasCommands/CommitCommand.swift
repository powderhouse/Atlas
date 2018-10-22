//
//  CommitCommand.swift
//  Atlas
//
//  Created by Jared Cosulich on 3/7/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

public class CommitCommand: Command {
    
    // Atlas commit -m {message} -p {project}
    
    public var atlasCore: AtlasCore
    
    public let name = "commit"
    public let shortDescription = "Commit all staged files with the provide commit message."
    
    public let message = Key<String>("-m", "--message", description: "The commit message.")
    public let project = Key<String>("-p", "--project", description: "The project the files reside in.")
    
    public init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    public func execute() throws  {
        if let projectName = project.value {
            if let project = atlasCore.project(projectName) {
                if let message = message.value {
                    if project.commitMessage(message) {
                        if project.commitStaged().success {
                            print("Files committed!")
                            print(atlasCore.commitChanges(message).allMessages)
                        } else {
                            print("Failed to commit files.")
                        }
                    } else {
                        print("Failed to save commit message.")
                    }
                } else {
                    if let commitMessage = project.currentCommitMessage() {
                        if project.commitStaged().success {
                            print("Files committed!")
                            atlasCore.commitChanges(commitMessage.text)
                        } else {
                            print("Failed to commit files.")
                        }
                    } else {
                        print("Please provide a commit message.")
                    }
                }
            } else {
                print("Failed to find or initialize project")
            }
        } else {
            print("Please specify a project name with -p or --project (e.g. -p MyProject)")
        }
    }
}

