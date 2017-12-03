//
//  Git.swift
//  atlas
//
//  Created by Jared Cosulich on 11/22/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Foundation

struct Credentials {
    let username: String
    let token: String
}

class Git {
    
    let deleteRepoToken = "5dd419d671aa4862ecd91159cfa839be64d0ab03"

    let path = "/usr/bin/env"
    var baseDirectory: URL
    var fullDirectory: URL
    var repositoryName: String!
    var atlasProcessFactory: AtlasProcessFactory!
    var credentials: Credentials?

    init?(_ directory: URL, username: String?=nil, password: String?=nil, atlasProcessFactory: AtlasProcessFactory=ProcessFactory()) {

        self.repositoryName = directory.lastPathComponent
        self.baseDirectory = directory.deletingLastPathComponent()
        self.fullDirectory = directory
        self.atlasProcessFactory = atlasProcessFactory

        credentials = getCredentials()
        
        if (username == nil || password == nil) && credentials == nil {
            return nil
        } else {
            setCredentials(username: username!, password: password!)
        }
    }
    
    func getCredentials() -> Credentials? {
        let path = fullDirectory.appendingPathComponent("github.json")
        var json: String
        do {
            json = try String(contentsOf: path, encoding: .utf8)
        }
        catch {
            return nil
        }
        
        if let data = json.data(using: .utf8) {
            do {
                if let credentialsDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                    if let username = credentialsDict["username"] {
                        if let token = credentialsDict["token"] {
                            return Credentials(
                                username: username,
                                token: token
                            )
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func setCredentials(username: String, password: String) {
        if let existingCredentials = getCredentials() {
            if existingCredentials.username == username {
                return
            }
        }
        
        let authArguments = [
            "-u", "\(username):\(password)",
            "-X", "POST",
            "https://api.github.com/authorizations",
            "-d", "{\"scopes\":[\"repo\", \"delete_repo\"], \"note\":\"Atlas Token\"}"
        ]

        if let authentication = callGitHubAPI(authArguments) {
            let credentials = [
                "username": username,
                "token": authentication["token"]
            ]
            
            do {
                let jsonCredentials = try JSONSerialization.data(
                    withJSONObject: credentials,
                    options: .prettyPrinted
                )
                
                do {
                    let filename = fullDirectory.appendingPathComponent("github.json")
                    try jsonCredentials.write(to: filename)
                } catch {}
            } catch {
                print("Failed to convert credentials to json")
            }
        }
        
    }

    func buildArguments(_ command: String, additionalArguments:[String]=[]) -> [String] {
        return ["git", "--git-dir=\(fullDirectory.path)/.git", command] + additionalArguments
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
            "-u", "\(credentials!.username):\(credentials!.token)",
            "https://api.github.com/user/repos",
            "-d", "{\"name\":\"\(repositoryName!)\"}"
        ]
        
        let result = callGitHubAPI(arguments)
        
        let repoPath = result!["clone_url"] as! String
        let authenticatedPath = repoPath.replacingOccurrences(
            of: "https://",
            with: "https://\(credentials!.username):\(credentials!.token)@"
        )
        _ = run("remote", arguments: ["add", "origin", authenticatedPath])
        
        return result
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
            "-u", "\(credentials!.username):\(credentials!.token)",
            "-X", "DELETE",
            "-H", "Authorization: token \(deleteRepoToken)",
//            "-H", "Authorization: token \(authentication!["token"]!)",
            "https://api.github.com/repos/\(credentials!.username)/\(credentials!.token)"
        ]

        _ = callGitHubAPI(deleteArguments)
    }
    
    func pushToGitHub() {
        _ = run("push", arguments: ["--set-upstream", "origin", "master"])
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
