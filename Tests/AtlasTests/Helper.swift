//
//  Helper.swift
//  AtlasCore
//
//  Created by Jared Cosulich on 2/13/18.
//

import Cocoa
import AtlasCore

class Helper {
    
    static let username = "atlasapptests"
    static let password = "1a2b3c4d"
    
    class func addFile(_ name: String, directory: URL) -> URL {
        let filePath = "\(directory.path)/\(name)"
        _ = Glue.runProcess("touch", arguments: [filePath])
        return URL(fileURLWithPath: filePath)
    }
    
    class func initAtlasCore(_ atlasCore: AtlasCore) -> Bool {
        let username = "atlasapptests"
        let password = "1a2b3c4d"
        
        let credentials = Credentials(username, password: password)
        if atlasCore.initGitAndGitHub(credentials) {
            _ = atlasCore.initProject("General")
            atlasCore.atlasCommit("Atlas Initialization")
        } else {
            return false
        }
        return true
    }
    
    class func deleteTestDirectory(_ testDirectory: URL) {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        let credentials = testDirectory.appendingPathComponent("credentials.json")
        let json = try? String(contentsOf: credentials, encoding: .utf8)
        if let data = json?.data(using: .utf8) {
            do {
                if let credentialsDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                    if let username = credentialsDict["username"] {
                        if let token = credentialsDict["token"] {
                            _ = Glue.runProcess("curl", arguments: [
                                "-u", "\(username):\(token)",
                                "-X", "DELETE",
                                "https://api.github.com/repos/\(username)/\(AtlasCore.repositoryName)"
                                ])
                        }
                    }
                }
            } catch {
            }
        }
        
        let fileManager = FileManager.default
        do {
            _ = Glue.runProcess(
                "chmod",
                arguments: ["-R", "u+w", testDirectory.path]
            )
            
            try fileManager.removeItem(at: testDirectory)
        } catch {
        }
    }
}

