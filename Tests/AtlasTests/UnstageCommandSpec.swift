//
//  UnstageCommandSpec.swift
//  AtlasTests
//
//  Created by Jared Cosulich on 3/6/18.
//


import Foundation
import Quick
import Nimble
import AtlasCore
import AtlasCommands

class UnstageCommandSpec: QuickSpec {
    override func spec() {
        
        describe("Unstage") {
            
            let projectName = "TestProject"
            
            var fileDirectory: URL!
            var file1: URL!
            
            var directory: URL!
            var atlasCore: AtlasCore!
            
            let fileManager = FileManager.default
            var isFile : ObjCBool = false
            
            var unstageCommand: UnstageCommand!
            
            beforeEach {
                let temp = URL(fileURLWithPath: NSTemporaryDirectory())
                fileDirectory = temp.appendingPathComponent("FILE_DIRECTORY")
                directory = temp.appendingPathComponent("ATLAS_CORE")
                
                FileSystem.createDirectory(fileDirectory)
                FileSystem.createDirectory(directory)
                
                file1 = Helper.addFile("index1.html", directory: fileDirectory)
                
                atlasCore = AtlasCore(directory)
                expect(Helper.initAtlasCore(atlasCore)).to(beTrue())
                _ = atlasCore.initProject(projectName)
                
                let importCommand = ImportCommand(atlasCore)
                importCommand.imports.value = [file1.path]
                if !importCommand.project.setValue(projectName) {
                    expect(false).to(beTrue(), description: "Failed to set project key value")
                }
                do {
                    try importCommand.execute()
                } catch {
                    expect(false).to(beTrue(), description: "Import command failed")
                }
                
                unstageCommand = UnstageCommand(atlasCore)
            }
            
            afterEach {
                atlasCore.deleteGitHubRepository()
                FileSystem.deleteDirectory(fileDirectory)
                FileSystem.deleteDirectory(directory)
            }
            
            context("running") {
                
                beforeEach {
                    unstageCommand.files.value = [file1.lastPathComponent]
                    _ = unstageCommand.project.setValue(projectName)
                    do {
                        try unstageCommand.execute()
                    } catch {
                        expect(false).to(beTrue(), description: "Unstage command failed")
                    }
                }
                
                it("should move the file into the project's unstaged folder") {
                    if let stagedURL = atlasCore.project(projectName)?.directory("staged") {
                        let filePath = stagedURL.appendingPathComponent(file1.lastPathComponent).path
                        let exists = fileManager.fileExists(atPath: filePath, isDirectory: &isFile)
                        expect(exists).to(beFalse(), description: "Staged file still found")
                    }

                    if let unstagedURL = atlasCore.project(projectName)?.directory("unstaged") {
                        let filePath = unstagedURL.appendingPathComponent(file1.lastPathComponent).path
                        let exists = fileManager.fileExists(atPath: filePath, isDirectory: &isFile)
                        expect(exists).to(beTrue(), description: "File not found in unstaged")
                    }
                }
                
                it("should sync with github") {
                    expect(atlasCore.status()).to(contain("nothing to commit"))
                    expect(false).to(beTrue())
                }
            }
        }
    }
}
