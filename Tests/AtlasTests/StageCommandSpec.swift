//
//  StageCommandSpec.swift
//  Atlas
//
//  Created by Jared Cosulich on 3/6/18.
//

import Foundation
import Quick
import Nimble
import AtlasCore
import Atlas

class StageCommandSpec: QuickSpec {
    override func spec() {
        
        describe("Unstage") {
            
            let projectName = "TestProject"
            
            var fileDirectory: URL!
            var file1: URL!
            
            var directory: URL!
            var atlasCore: AtlasCore!
            
            let fileManager = FileManager.default
            var isFile : ObjCBool = false
            
            var stageCommand: StageCommand!
            
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
                
                let unstageCommand = UnstageCommand(atlasCore)
                unstageCommand.files.value = [file1.path]
                if !unstageCommand.project.setValue(projectName) {
                    expect(false).to(beTrue(), description: "Failed to set project key value")
                }
                do {
                    try unstageCommand.execute()
                } catch {
                    expect(false).to(beTrue(), description: "Unstage command failed")
                }
                
                stageCommand = StageCommand(atlasCore)
            }
            
            afterEach {
                atlasCore.deleteGitHubRepository()
                FileSystem.deleteDirectory(fileDirectory)
                FileSystem.deleteDirectory(directory)
            }
            
            context("running") {
                
                beforeEach {
                    stageCommand.files.value = [file1.lastPathComponent]
                    _ = stageCommand.project.setValue(projectName)
                    do {
                        try stageCommand.execute()
                    } catch {
                        expect(false).to(beTrue(), description: "Stage command failed")
                    }
                }
                
                it("should move the file into the project's staged folder") {
                    if let unstagedURL = atlasCore.project(projectName)?.directory("unstaged") {
                        let filePath = unstagedURL.appendingPathComponent(file1.lastPathComponent).path
                        let exists = fileManager.fileExists(atPath: filePath, isDirectory: &isFile)
                        expect(exists).to(beFalse(), description: "File still found in unstaged")
                    }

                    if let stagedURL = atlasCore.project(projectName)?.directory("staged") {
                        let filePath = stagedURL.appendingPathComponent(file1.lastPathComponent).path
                        let exists = fileManager.fileExists(atPath: filePath, isDirectory: &isFile)
                        expect(exists).to(beTrue(), description: "Staged file not found")
                    }
                }
            }
        }
    }
}
