//
//  Git.swift
//  atlas
//
//  Created by Jared Cosulich on 11/22/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Foundation

class Git {
    
    let remoteUser = "atlastest"
    let remotePassword = "1a2b3c4d"
    
    let path = "/usr/bin/git"
    var baseDirectory: URL
    var fullDirectory: URL
    var repositoryName: String!
    var atlasProcessFactory: AtlasProcessFactory!

    init(_ directory: URL, atlasProcessFactory: AtlasProcessFactory=ProcessFactory()) {
        self.repositoryName = directory.lastPathComponent
        self.baseDirectory = directory.deletingLastPathComponent()
        self.fullDirectory = directory
        self.atlasProcessFactory = atlasProcessFactory
    }

    func buildArguments(_ command: String, additionalArguments:[String]=[]) -> [String] {
        return ["--git-dir=\(fullDirectory.path)/.git", command] + additionalArguments
    }
    
    func run(_ command: String, arguments: [String]=[]) -> String {
        let fullArguments = buildArguments(
            command,
            additionalArguments: arguments
        )
        return Glue.runProcess(path, arguments: fullArguments, currentDirectory: fullDirectory, atlasProcess: atlasProcessFactory.build())
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
    
    func add(_ filter: String=".") -> Bool {
        _ = run("add", arguments: ["."])
        
        return true
    }
    
    func initGitHub() {
//        curl
//        Glue.run("curl", arguments: [
//            "-u '\(remoteUser)'",
//            "https://api.github.com/user/repos",
//            "-d "{\"name\":\"$\()\"}"
//        ])
    }
    
    func commit() -> String {
        return run("commit", arguments: ["-am", "Atlas commit"])
    }
    
}
