//
//  ProjectsCommand.swift
//  AtlasApp
//
//  Created by Jared Cosulich on 4/7/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

public class ProjectsCommand: Command {
    
    public var atlasCore: AtlasCore
    
    public let name = "projects"
    public let shortDescription = "List of Atlas project."
    
    public init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    public func execute() throws  {
        let projectNames = atlasCore.projects().map { $0.name! }
        print("Atlas Projects:\n\n\(projectNames.joined(separator: "\n"))")
    }
}

