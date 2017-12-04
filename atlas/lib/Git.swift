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
    
    static let path = "/usr/bin/env"
    static let credentialsFilename = "github.json"
    
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
    
    class func getCredentials(_ baseDirectory: URL) -> Credentials? {
        let path = baseDirectory.appendingPathComponent(credentialsFilename)
        var json: String
        do {
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
        guard newCredentials.token == nil else {
            return
        }

        var credentials = newCredentials
        let existingCredentials = Git.getCredentials(baseDirectory)
        
        
        if credentials.username == existingCredentials?.username {
            credentials.token = existingCredentials?.token
        }
        
        if credentials.token == nil {
            credentials.token = getAuthenticationToken(credentials)
        }
        self.credentials = credentials
    }
        
    func getAuthenticationToken(_ credentials: Credentials) -> String? {
        let listArguments = [
            "-u", "\(credentials.username):\(credentials.password!)",
            "https://api.github.com/authorizations"
        ]
        
        if let list = callGitHubAPI(listArguments) {
            for item in list {
                if (item["note"] as? String) == "Atlas Token" {
                    print ("ITEM FOUND: \(item)")
                    let deleteAuthArguments = [
                        "-u", "\(credentials.username):\(credentials.password!)",
                        "-X", "DELETE",
                        "https://api.github.com/authorizations/\(item["id"]!)"
                    ]
                    _ = callGitHubAPI(deleteAuthArguments)
                }
            }
        }
        
        let authArguments = [
            "-u", "\(credentials.username):\(credentials.password!)",
            "-X", "POST",
            "https://api.github.com/authorizations",
            "-d", "{\"scopes\":[\"repo\", \"delete_repo\"], \"note\":\"Atlas Token\"}"
        ]
        
        if let authentication = callGitHubAPI(authArguments) {
            guard authentication[0]["token"] != nil else {
                print("Failed GitHub Authentication: \(authentication)")
                return nil
            }
            
            return authentication[0]["token"] as? String
        }
        return nil
    }
        
    func saveCredentials(_ credentials: Credentials) {
        guard credentials.token != nil else {
            print("No token provided: \(credentials)")
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
                let filename = baseDirectory.appendingPathComponent(Git.credentialsFilename)
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
        return Glue.runProcess(Git.path, arguments: fullArguments, currentDirectory: fullDirectory, atlasProcess: atlasProcessFactory.build())
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
        
        guard let repoPath = result![0]["clone_url"] as? String else {
            return nil
        }
        
        let authenticatedPath = repoPath.replacingOccurrences(
            of: "https://",
            with: "https://\(credentials.username):\(credentials.token!)@"
        )
        _ = run("remote", arguments: ["add", "origin", authenticatedPath])
        
        return result![0]
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
            "-X", "DELETE",
            "-H", "Authorization: token \(credentials.token!)",
            "https://api.github.com/repos/\(credentials.username)/\(repositoryName!)"
        ]

        _ = callGitHubAPI(deleteArguments)
    }
    
    func pushToGitHub() {
        _ = run("push", arguments: ["--set-upstream", "origin", "master"])
    }
    
    func callGitHubAPI(_ arguments: [String]) -> [[String: Any]]? {
        let response = Glue.runProcess("/anaconda/bin/curl", arguments: arguments)
        print("GITHUB RESPONSE: \(response)")

        let data = response.data(using: .utf8)!
        
        do {
            let json = try JSONSerialization.jsonObject(with: data)
            
            if let singleItem = json as? [String: Any] {
                return [singleItem]
            } else if let multipleItems = json as? [[String: Any]] {
                return multipleItems
            }
            print("JSON response from GITHUB evaluates to nil: \(response)")
        } catch {
            print("Error deserializing JSON: \(error)")
        }
        return nil
    }

    func commit() -> String {
        return run("commit", arguments: ["-am", "Atlas commit"])
    }
    
}
