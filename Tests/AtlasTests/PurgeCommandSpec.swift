//
//  PurgeCommandSpec.swift
//  AtlasTests
//
//  Created by Jared Cosulich on 3/16/18.
//

import Foundation
import Quick
import Nimble
import AtlasCore
import AtlasCommands

class PurgeCommandSpec: QuickSpec {
    override func spec() {

        describe("Purge") {
            
            let projectName = "TestProject"
            
            var fileDirectory: URL!
            var file1: URL!
            
            var directory: URL!
            var atlasCore: AtlasCore!
            
            let fileManager = FileManager.default
            var isFile : ObjCBool = false
            var isDirectory : ObjCBool = true

            var project: Project!

            let commitMessage = "This it the message for the commit."
            var commitUrl: URL!
            var slug: String!
            var commitFolder: URL!

            var purgeCommand: PurgeCommand!

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
                
                let commitCommand = CommitCommand(atlasCore)

                _ = commitCommand.message.setValue(commitMessage)
                _ = commitCommand.project.setValue(projectName)
                do {
                    try commitCommand.execute()
                } catch {
                    expect(false).to(beTrue(), description: "Commit command failed")
                }
                
                project = atlasCore.project(projectName)
                
                guard project != nil else  {
                    expect(false).to(beTrue(), description: "Project not found")
                    return
                }
                
                commitUrl = project!.directory("committed")
                slug = project!.commitSlug(commitMessage)
                commitFolder = commitUrl.appendingPathComponent(slug)
                
                purgeCommand = PurgeCommand(atlasCore)
            }
            
            afterEach {
                atlasCore.deleteGitHubRepository()
                FileSystem.deleteDirectory(fileDirectory)
                FileSystem.deleteDirectory(directory)
            }
            
            context("running") {

                var fileName: String!
                var filePath: String!
                
                beforeEach {
                    fileName = file1.lastPathComponent
                    filePath = commitFolder.appendingPathComponent(fileName).path
                    
                    purgeCommand.files.value = [filePath]
                    purgeCommand.project.setValue(projectName)
                    
                    do {
                        try purgeCommand.execute()
                    } catch {
                        expect(false).to(beTrue(), description: "Purge command failed")
                    }
                }
                
//                it("should remove the file from the committed folder") {
//                    let exists = fileManager.fileExists(atPath: filePath, isDirectory: &isFile)
//                    expect(exists).to(beFalse(), description: "Committed file still found")
//                }
//                
//                it("should should remove the commit from the log") {
//                }
            }
        }
    }
}




