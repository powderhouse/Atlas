//
//  InfoCommand.swift
//  Atlas
//
//  Created by Jared Cosulich on 2/14/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

class ImportCommand: Command {
    
    // Atlas import -f {files} -p {project} -u {urls}
    
    var atlasCore: AtlasCore
    
    let name = "import"
    let shortDescription = "Import (copy) one or more files or urls into an Atlas project."
    
    let filesType = Flag("-f", "--files", description: "Import files into the project.")
    let urlsType = Flag("-u", "--urls", description: "Import urls into the project.")
    let imports = CollectedParameter()
    let project = Key<String>("-p", "--project", description: "The project you want to import the files into.")

    init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
    }
    
    func execute() throws  {
        print("filesType: \(filesType.value)")
        print("urlsType: \(urlsType.value)")
        print("imports: \(imports.value)")
        print("PROJECT: \(project.value)")
    }
}


