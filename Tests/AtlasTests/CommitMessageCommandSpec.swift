//
//  CommitMessageCommandSpec.swift
//  Atlas
//
//  Created by Jared Cosulich on 3/13/18.
//

import Foundation
import Quick
import Nimble
import AtlasCore
import AtlasCommands

class CommitMessageCommandSpec: QuickSpec {
    override func spec() {
        
        describe("CommitMessage") {
            
            let projectName = "TestProject"
            
            var directory: URL!
            var atlasCore: AtlasCore!
            
            let fileManager = FileManager.default
            var isFile : ObjCBool = false
            
            var commitMessageCommand: CommitMessageCommand!
            let commitMessage = "This it the message for the commit."
            
            beforeEach {
                let temp = URL(fileURLWithPath: NSTemporaryDirectory())
                directory = temp.appendingPathComponent("ATLAS_CORE")
                
                FileSystem.createDirectory(directory)
                
                atlasCore = AtlasCore(directory)
                expect(Helper.initAtlasCore(atlasCore)).to(beTrue())
                _ = atlasCore.initProject(projectName)
                
                commitMessageCommand = CommitMessageCommand(atlasCore)
            }
            
            afterEach {
                atlasCore.deleteGitHubRepository()
                FileSystem.deleteDirectory(directory)
            }
            
            context("running") {
                
                var project: Project!
                
                beforeEach {
                    _ = commitMessageCommand.message.setValue(commitMessage)
                    _ = commitMessageCommand.project.setValue(projectName)
                    do {
                        try commitMessageCommand.execute()
                    } catch {
                        expect(false).to(beTrue(), description: "Commit message command failed")
                    }
                    
                    project = atlasCore.project(projectName)
                    
                    guard project != nil else  {
                        expect(false).to(beTrue(), description: "Project not found")
                        return
                    }
                    
                }
                
                it("should create a commit_message.txt file in the project folder containing the commit message") {
                    if let projectURL = project?.directory() {
                        let commitMessageFileUrl = projectURL.appendingPathComponent("commit_message.txt")
                        let exists = fileManager.fileExists(atPath: commitMessageFileUrl.path, isDirectory: &isFile)
                        expect(exists).to(beTrue(), description: "Commit message file not found")
                        
                        do {
                            let contents = try String(contentsOf: commitMessageFileUrl, encoding: .utf8)
                            expect(contents).to(equal(commitMessage))
                        } catch {
                            expect(false).to(beTrue(), description: "unable to load contents")
                        }
                    }
                }
            }
        }
    }
}

