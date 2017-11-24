//
//  Git.swift
//  atlas
//
//  Created by Jared Cosulich on 11/22/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Foundation

class Git {
    
    let path = "/usr/bin/git"
    var directoryPath: String!
    var atlasProcessFactory: AtlasProcessFactory!

    init(_ directory: URL, atlasProcessFactory: AtlasProcessFactory=ProcessFactory()) {
        self.directoryPath = directory.path
        self.atlasProcessFactory = atlasProcessFactory
    }

    func buildArguments(_ command: String, directoryPath: String) -> [String] {
        return ["--git-dir=\(directoryPath)/.git", command]
    }
    
    func run(_ command: String) -> String {
        let arguments = buildArguments(command, directoryPath: directoryPath)
        return Glue.runProcess(path, arguments: arguments, atlasProcess: atlasProcessFactory.build())
    }
    
    func runInit() -> String {
        return run("init")
    }
    
    func status() -> String? {
        let result = run("status")
        print("PRINTING RESULT: \(result)")
        if (result == "") {
            return nil
        }
        return result
    }
    
}
