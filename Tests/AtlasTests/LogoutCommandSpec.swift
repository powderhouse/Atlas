//
//  LogoutCommandSpec.swift
//  AtlasTests
//
//  Created by Jared Cosulich on 3/6/18.
//

import Foundation
import Quick
import Nimble
import AtlasCore
import AtlasCommands

class LogoutCommandSpec: QuickSpec {
    override func spec() {
        
        describe("Logout") {

            var directory: URL!
            var atlasCore: AtlasCore!
            var logoutCommand: LogoutCommand!
            
            let fileManager = FileManager.default
            var isFile : ObjCBool = false
            
            beforeEach {
                directory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("ATLAS_CORE")
                Helper.deleteTestDirectory(directory)
                FileSystem.createDirectory(directory)

                atlasCore = AtlasCore(directory)
                expect(Helper.initAtlasCore(atlasCore)).to(beTrue())

                logoutCommand = LogoutCommand(atlasCore)
            }
            
            afterEach {
                Helper.deleteTestDirectory(directory)
            }
            
            context("running") {
                
                beforeEach {
                    do {
                        try logoutCommand.execute()
                    } catch {
                        expect(false).to(beTrue(), description: "Logout command failed")
                    }
                }
                
                it("removes credentials from the filesystem") {
                    let credentialsFile = directory.appendingPathComponent("credentials.json")
                    let exists = fileManager.fileExists(atPath: credentialsFile.path, isDirectory: &isFile)
                    expect(exists).to(beFalse(), description: "credentials.json still exists")
                }
            }
        }
    }
}

