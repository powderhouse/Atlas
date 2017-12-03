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
    let password: String?
    var token: String?
}

class Git {
    
    let deleteRepoToken = "5dd419d671aa4862ecd91159cfa839be64d0ab03"

    let path = "/usr/bin/env"
    let credentialsFilename = "github.json"
    
    var baseDirectory: URL
    var fullDirectory: URL
    var repositoryName: String!
    var atlasProcessFactory: AtlasProcessFactory!
    var credentials: Credentials!

    init?(_ directory: URL, credentials: Credentials, atlasProcessFactory: AtlasProcessFactory=ProcessFactory()) {

        self.repositoryName = directory.lastPathComponent
        self.baseDirectory = directory.deletingLastPathComponent()
        self.fullDirectory = directory
        self.atlasProcessFactory = atlasProcessFactory

        syncCredentials(credentials)
        saveCredentials(credentials)
        
        if credentials.token == nil {
            return nil
        }
    }
    
    func getCredentials() -> Credentials? {
        let path = baseDirectory.appendingPathComponent(credentialsFilename)
        var json: String
        do {
            print("PATH: \(path)")
            json = try String(contentsOf: path, encoding: .utf8)
        }
        catch {
            print("GitHub Credentials Not Found")
            return nil
        }
        
        if let data = json.data(using: .utf8) {
            do {
                if let credentialsDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                    if let username = credentialsDict["username"] {
                        if let token = credentialsDict["token"] {
                            return Credentials(
                                username: username,
                                password: nil,
                                token: token
                            )
                        }
                    }
                }
            } catch {
                print("GitHub Credentials Loading Error")
                print(error.localizedDescription)
            }
        }
        return nil
    }

    
    func syncCredentials(_ newCredentials: Credentials) {
        var credentials = newCredentials
        let existingCredentials = getCredentials()
        
        guard credentials.token != nil else {
            return
        }
        
        if credentials.username == existingCredentials?.username {
            credentials.token = existingCredentials?.token
        }
        
        if credentials.token == nil {
            credentials.token = getAuthenticationToken(credentials)
        }
        self.credentials = credentials
    }
        
    func getAuthenticationToken(_ credentials: Credentials) -> String? {
        let authArguments = [
            "-u", "\(credentials.username):\(credentials.password!)",
            "-X", "POST",
            "https://api.github.com/authorizations",
            "-d", "{\"scopes\":[\"repo\", \"delete_repo\"], \"note\":\"Atlas Token\"}"
        ]
        
        if let authentication = callGitHubAPI(authArguments) {
            guard authentication["token"] != nil else {
                print("Failed GitHub Authentication: \(authentication)")
                return nil
            }
            
            return authentication["token"] as? String
        }
        return nil
    }
        
    func saveCredentials(_ credentials: Credentials) {
        guard credentials.token != nil else {
            print("No token provided")
            return
        }
        
        do {
            let jsonCredentials = try JSONSerialization.data(
                withJSONObject: [
                    "username": credentials.username,
                    "token": credentials.token!
                ],
                options: .prettyPrinted
            )
            
            do {
                let filename = baseDirectory.appendingPathComponent(credentialsFilename)
                try jsonCredentials.write(to: filename)
            } catch {}
        } catch {
            print("Failed to convert credentials to json")
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
            "-u", "\(credentials.username):\(credentials.token!)",
            "-H", "Authorization: token \(credentials.token!)",
            "https://api.github.com/user/repos",
            "-d", "{\"name\":\"\(repositoryName!)\"}"
        ]
        
        let result = callGitHubAPI(arguments)
        
        guard let repoPath = result!["clone_url"] as? String else {
            return nil
        }
        
        let authenticatedPath = repoPath.replacingOccurrences(
            of: "https://",
            with: "https://\(credentials.username):\(credentials.token!)@"
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
            "-u", "\(credentials.username):\(credentials.token!)",
            "-H", "Authorization: token \(credentials.token!)",
            "-X", "DELETE",
            "-H", "Authorization: token \(credentials.token!)",
//            "-H", "Authorization: token \(authentication!["token"]!)",
            "https://api.github.com/repos/\(credentials.username)/\(credentials.token!)"
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
