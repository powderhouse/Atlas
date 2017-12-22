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
    
    static let credentialsFilename = "github.json"
    
    var repositoryDirectory: URL
    var baseDirectory: URL
    var repositoryName: String
    
    var githubRepositoryLink: String?
    
    var atlasProcessFactory: AtlasProcessFactory!
    var credentials: Credentials!

    init?(_ repositoryDirectory: URL, credentials: Credentials, atlasProcessFactory: AtlasProcessFactory=ProcessFactory()) {

        self.repositoryDirectory = repositoryDirectory
        self.baseDirectory = repositoryDirectory.deletingLastPathComponent()
        self.repositoryName = repositoryDirectory.lastPathComponent
        self.atlasProcessFactory = atlasProcessFactory

        syncCredentials(credentials)
        saveCredentials(self.credentials)

        if self.credentials.token == nil {
            return nil
        }
        
        setGitHubRepositoryLink()
    }
    
    class func getCredentials(_ baseDirectory: URL) -> Credentials? {
        let path = baseDirectory.appendingPathComponent(credentialsFilename)
        var json: String
        do {
            json = try String(contentsOf: path, encoding: .utf8)
        }
        catch {
            printGit("GitHub Credentials Not Found")
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
                printGit("GitHub Credentials Loading Error")
                printGit(error.localizedDescription)
            }
        }
        return nil
    }

    
    func syncCredentials(_ newCredentials: Credentials) {
        guard newCredentials.token == nil else {
            self.credentials = newCredentials
            return
        }

        var credentials = newCredentials
        let existingCredentials = Git.getCredentials(baseDirectory)
        
        if credentials.username == existingCredentials?.username {
            credentials.token = existingCredentials?.token
        }
        
        if credentials.token == nil && credentials.password != nil {
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
                printGit("Failed GitHub Authentication: \(authentication)")
                return nil
            }

            return authentication[0]["token"] as? String
        }
        return nil
    }
        
    func saveCredentials(_ credentials: Credentials) {
        guard credentials.token != nil else {
            printGit("No token provided: \(credentials)")
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

                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: filename.path) {
                    do {
                        try fileManager.removeItem(at: filename)
                    } catch {
                        printGit("Failed to delete github.json: \(error)")
                    }
                }
                
                try jsonCredentials.write(to: filename)
            } catch {
                printGit("Failed to save github.json: \(error)")
            }
        } catch {
            printGit("Failed to convert credentials to json")
        }
    }
    
    func buildArguments(_ command: String, additionalArguments:[String]=[]) -> [String] {
        let path = repositoryDirectory.path
        return ["--git-dir=\(path)/.git", command] + additionalArguments
    }
    
    func run(_ command: String, arguments: [String]=[]) -> String {
        let fullArguments = buildArguments(
            command,
            additionalArguments: arguments
        )
        
        return Glue.runProcess("git",
                               arguments: fullArguments,
                               currentDirectory: repositoryDirectory,
                               atlasProcess: atlasProcessFactory.build()
        )
    }
    
    func runInit() -> String {
        return run("init")
    }
    
    func status() -> String? {
        let result = run("status")
        if (result == "") {
            return nil
        }
        return result
    }
    
    func logNameOnly(_ projects: [Project]) -> String {
        let arguments = [
            "--pretty=format:\n\n%s\n",
            "--reverse",
            "--name-only",
            "--",
            ".",
            ":^*/staging/*"
        ]
        
        let log = run("log", arguments: arguments)
        var processedLog = log

        let rawGitHub = githubRepositoryLink?.replacingOccurrences(
            of: "github.com",
            with: "raw.githubusercontent.com"
        ) ?? "INVALID"
        
        for project in projects {
            if let projectName = project.name {
                do {
                    let regex = try NSRegularExpression(
                        pattern: "\(projectName)/([^\n]+)",
                        options: .caseInsensitive
                    )

                    let range = NSMakeRange(0, log.count)

                    regex.enumerateMatches(
                        in: log,
                        options: .withoutAnchoringBounds,
                        range: range,
                        using: { (match, flags, stop) in
                            if let matchRange = match?.range {
                                let result = String(log.substring(with: matchRange)!)
                                let noSpacesResult = result.replacingOccurrences(of: " ", with: "%20")
                                let newResult = "\(result): \(rawGitHub)/master/\(noSpacesResult)\n"
                                print("MATCH: \(result) -> \(newResult)")
                                processedLog = processedLog.replacingOccurrences(of: result, with: newResult)
                            }
                    })
                    
//                    log = regex.stringByReplacingMatches(
//                        in: log,
//                        options: .withoutAnchoringBounds,
//                        range: range,
//                        withTemplate: template
//                    )
                } catch {
                    print("ERROR!!! \(error)")
                }
            }
        }
        
        return processedLog
    }
    
    func add(_ filter: String=".") -> Bool {
        _ = run("add", arguments: ["."])
        
        return true
    }
    
    func url() -> String {
        let authenticatedUrl = run("ls-remote", arguments: ["--get-url"])
        
        guard authenticatedUrl.contains("https") else {
            return ""
        }
        
        return authenticatedUrl.replacingOccurrences(
            of: "https://\(credentials.username):\(credentials.token!)@",
            with: "https://"
        )
    }
    
    func initGitHub() -> [String: Any]? {
        let repoArguments = [
            "-u", "\(credentials.username):\(credentials.token!)",
            "https://api.github.com/repos/\(credentials.username)/\(repositoryName)"
        ]
        
        var repoResult = callGitHubAPI(repoArguments)
        
        var repoPath = repoResult?[0]["clone_url"] as? String
        
        if repoPath == nil {
            let createRepoArguments = [
                "-u", "\(credentials.username):\(credentials.token!)",
                "https://api.github.com/user/repos",
                "-d", "{\"name\":\"\(repositoryName)\"}"
            ]
            
            repoResult = callGitHubAPI(createRepoArguments)
            
            repoPath = repoResult?[0]["clone_url"] as? String
        }
        
        guard repoPath != nil else {
            return nil
        }
        
        let authenticatedPath = repoPath!.replacingOccurrences(
            of: "https://",
            with: "https://\(credentials.username):\(credentials.token!)@"
        )
        _ = run("remote", arguments: ["add", "origin", authenticatedPath])
        
        setGitHubRepositoryLink()
        
        return repoResult![0]
    }
    
    func setGitHubRepositoryLink() {
        githubRepositoryLink = url().replacingOccurrences(of: ".git\n", with: "")
    }

    func removeGitHub() {
        let deleteArguments = [
            "-u", "\(credentials.username):\(credentials.token!)",
            "-X", "DELETE",
            "https://api.github.com/repos/\(credentials.username)/\(repositoryName)"
        ]

        _ = callGitHubAPI(deleteArguments)
    }
    
    func pushToGitHub() {
        _ = run("push", arguments: ["--set-upstream", "origin", "master"])
    }
    
    func callGitHubAPI(_ arguments: [String]) -> [[String: Any]]? {
        let response = Glue.runProcess("curl", arguments: arguments)
        
        guard response.count > 0 else {
            return nil
        }
        
        let data = response.data(using: .utf8)!
        
        do {
            let json = try JSONSerialization.jsonObject(with: data)
            
            if let singleItem = json as? [String: Any] {
                return [singleItem]
            } else if let multipleItems = json as? [[String: Any]] {
                return multipleItems
            }
            printGit("JSON response from GITHUB evaluates to nil for \(arguments): \(response)")
        } catch {
            printGit("Error deserializing JSON for \(arguments) -> \(response): \(error)")
        }
        return nil
    }

    func commit(_ message: String?=nil) -> String {
        return run("commit", arguments: ["-am", message ?? "Atlas commit"])
    }
    
    func printGit(_ output: String) {
        Git.printGit(output)
    }
    
    class func printGit(_ output: String) {
        print("GIT: \(output)")
    }
    
}
