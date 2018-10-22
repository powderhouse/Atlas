//
//  StartProjectCommandSpec.swift
//  AtlasTests
//
//  Created by Jared Cosulich on 3/6/18.
//

import Foundation
import Quick
import Nimble
import AtlasCore
import AtlasCommands

class StartProjectCommandSpec: QuickSpec {
    override func spec() {
        
        describe("Start Project") {
            let projectName = "TestProject"
            
            var directory: URL!
            var atlasCore: AtlasCore!
            
            let fileManager = FileManager.default
            var isFile : ObjCBool = false
            var isDirectory : ObjCBool = true

            var startProjectCommand: StartProjectCommand!
            
            beforeEach {
                let temp = URL(fileURLWithPath: NSTemporaryDirectory())
                directory = temp.appendingPathComponent("ATLAS_CORE")
                
                Helper.deleteTestDirectory(directory)
                _ = FileSystem.createDirectory(directory)
                
                atlasCore = AtlasCore(directory)
                expect(Helper.initAtlasCore(atlasCore)).to(beTrue())
                
                startProjectCommand = StartProjectCommand(atlasCore)
            }
            
            afterEach {
                Helper.deleteTestDirectory(directory)
            }
            
            
            context("running") {
                
                beforeEach {
                    startProjectCommand.project.update(value: "Test Project")
                    do {
                        try startProjectCommand.execute()
                    } catch {
                        expect(false).to(beTrue(), description: "Start project command failed")
                    }
                }
                
                it("creates all subfolders with a readme in each") {
                    if let projectDirectory = atlasCore.project(projectName)?.directory() {
                        for subfolderName in ["unstaged", "staged", "committed"] {
                            let subfolder = projectDirectory.appendingPathComponent(subfolderName)
                            let folderExists = fileManager.fileExists(atPath: subfolder.path, isDirectory: &isDirectory)
                            expect(folderExists).to(beTrue(), description: "No subfolder found")
                            
                            let readme = subfolder.appendingPathComponent(Project.readme)
                            let readmeExists = fileManager.fileExists(atPath: readme.path, isDirectory: &isFile)
                            expect(readmeExists).to(beTrue(), description: "No readme found")
                        }
                    } else {
                        expect(false).to(beTrue(), description: "Project directory was not set")
                    }
                }
                
                it("should sync with github") {
                    expect(atlasCore.status()).to(contain("nothing to commit"))
                }
                
            }
        }
    }
}

