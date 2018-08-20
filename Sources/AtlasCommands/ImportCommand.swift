//
//  InfoCommand.swift
//  Atlas
//
//  Created by Jared Cosulich on 2/14/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

public class ImportCommand: Command {
    
    // Atlas import -f {files} -p {project} -u {urls}
    
    public var atlasCore: AtlasCore
    
    public let name = "import"
    public let shortDescription = "Import (copy) one or more files or urls into an Atlas project."
    
    public let filesType = Flag("-f", "--files", description: "Import files into the project.")
    public let urlsType = Flag("-u", "--urls", description: "Import urls into the project.")
    public let imports = CollectedParameter()
    public let project = Key<String>("-p", "--project", description: "The project you want to import the files into.")

    public init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    public func execute() throws  {
        if let projectName = project.value {
            if let project = atlasCore.project(projectName) {
                if project.copyInto(imports.value).success {
                    print("Files successfully imported into \(projectName)")
                    atlasCore.atlasCommit("Importing files into \(projectName)")
                } else {
                    print("Failed to import files.")
                }
            }
        } else {
            print("Please specify a project name with -p or --project (e.g. -p MyProject)")
        }
    }
}


