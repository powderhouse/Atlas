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
    static let email = "atlasapptests@puzzleschool.com"
    
    class func addFile(_ name: String, directory: URL) -> URL {
        let filePath = "\(directory.path)/\(name)"
        _ = Glue.runProcess("touch", arguments: [filePath])
        return URL(fileURLWithPath: filePath)
    }
    
    class func initAtlasCore(_ atlasCore: AtlasCore) -> Bool {
//        let credentials = Credentials(username, password: password)
        let credentials = Credentials(Helper.username, email: Helper.email)
        if atlasCore.initGitAndGitHub(credentials).success {
            _ = atlasCore.initProject("General")
            print(atlasCore.atlasCommit("Atlas Initialization").allMessages)
        } else {
            return false
        }
        return true
    }
    
    class func deleteTestDirectory(_ testDirectory: URL) {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        let credentials = testDirectory.appendingPathComponent("credentials.json")
//        let json = try? String(contentsOf: credentials, encoding: .utf8)
//        if let data = json?.data(using: .utf8) {
//            do {
//                if let credentialsDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
//                    if let username = credentialsDict["username"] {
//                        if let token = credentialsDict["token"] {
//                            _ = Glue.runProcess("curl", arguments: [
//                                "-u", "\(username):\(token)",
//                                "-X", "DELETE",
//                                "https://api.github.com/repos/\(username)/\(AtlasCore.repositoryName)"
//                                ])
//                        }
//                    }
//                }
//            } catch {
//            }
//        }

        while FileSystem.fileExists(testDirectory) {
            _ = Glue.runProcess(
                "chmod",
                arguments: ["-R", "u+w", testDirectory.path],
                currentDirectory: testDirectory.deletingLastPathComponent()
            )
            _ = FileSystem.deleteDirectory(testDirectory)
        }
    }
}

