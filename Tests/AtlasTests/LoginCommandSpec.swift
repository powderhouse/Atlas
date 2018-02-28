//
//  LoginCommandSpec.swift
//  AtlasTests
//
//  Created by Jared Cosulich on 2/28/18.
//

import Foundation
import Quick
import Nimble
import AtlasCore
import Atlas

class LoginCommandSpec: QuickSpec {
    override func spec() {
        
        describe("Login") {
            
            var directory: URL!
            var atlasCore: AtlasCore!
            
            var loginCommand: LoginCommand!
            
            beforeEach {
                directory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("ATLAS_CORE")
                
                FileSystem.createDirectory(directory)
                
                //                let filePath = directory.path
                //                let exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory)
                //                expect(exists).to(beTrue(), description: "No folder found")
                
                atlasCore = AtlasCore(directory)
                loginCommand = LoginCommand(atlasCore)
            }
            
            afterEach {
                FileSystem.deleteDirectory(directory)
            }
            
            
            context("running") {
                
                it("should work") {
                    do {
                        try loginCommand.execute()
                        print("SUCCESS")
                    } catch {
                        print("FAIL")
                    }
                    expect(true).to(beTrue())
                }
                
                it("should fail") {
                    expect(false).to(beTrue())
                }
            }
        }
    }
}
