//
//  StartProjectCommand.swift
//  Atlas
//
//  Created by Jared Cosulich on 2/16/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

public class StartProjectCommand: Command {
    
    public var atlasCore: AtlasCore
    
    public let name = "start"
    public let shortDescription = "Start a new Atlas project."
    
    public let project = Parameter()

    public init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    public func execute() throws  {
        if atlasCore.initProject(project.value) {
            print("Project Started: \(project.value)")
            atlasCore.atlasCommit("\(name) Project Initialization")
        } else {
            print("There was an error creating this project.")
        }
    }
}
