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
    let deleteRepoToken = "5dd419d671aa4862ecd91159cfa839be64d0ab03"
    
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
    
    func initGitHub() -> [String: Any]? {
        let arguments = [
            "-u", "\(remoteUser):\(remotePassword)",
            "https://api.github.com/user/repos",
            "-d", "{\"name\":\"\(repositoryName!)\"}"
        ]
        
        return callGitHubAPI(arguments)
    }

    func removeGitHub() {
//        let authArguments = [
//            "-u", "\(remoteUser):\(remotePassword)",
//            "-X", "POST",
//            "https://api.github.com/authorizations",
//            "-d", "{\"scopes\":[\"delete_repo\"], \"note\":\"Test Token\"}"
//        ]
//
//        let authArguments = [
//            "-u", "\(remoteUser):\(remotePassword)",
//            "https://api.github.com/authorizations/147415484"
//        ]
//
//        let authentication = callGitHubAPI(authArguments)
//
//        print(authentication)
        
        let deleteArguments = [
            "-u", "\(remoteUser):\(remotePassword)",
            "-X", "DELETE",
            "-H", "Authorization: token \(deleteRepoToken)",
//            "-H", "Authorization: token \(authentication!["token"]!)",
            "https://api.github.com/repos/\(remoteUser)/\(repositoryName!)"
        ]

        _ = callGitHubAPI(deleteArguments)
    }
    
    func callGitHubAPI(_ arguments: [String]) -> [String: Any]? {
        let response = Glue.runProcess("/anaconda/bin/curl", arguments: arguments)
        let data = response.data(using: .utf8)!
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                return json
            }
        } catch {
            print("Error deserializing JSON: \(error)")
        }
        return nil
    }

    func commit() -> String {
        return run("commit", arguments: ["-am", "Atlas commit"])
    }
    
}
