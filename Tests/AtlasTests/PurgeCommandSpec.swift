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

class PurgeCommandSpec: CliSpec {
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
                
                Helper.deleteTestDirectory(directory)
                _ = FileSystem.createDirectory(fileDirectory)
                _ = FileSystem.createDirectory(directory)
                
                file1 = Helper.addFile("index1.html", directory: fileDirectory)
                
                atlasCore = AtlasCore(directory)
                expect(Helper.initAtlasCore(atlasCore)).to(beTrue())
                _ = atlasCore.initProject(projectName)

                project = atlasCore.project(projectName)
                
                guard project != nil else  {
                    expect(false).to(beTrue(), description: "Project not found")
                    return
                }

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

                commitUrl = project!.directory("committed")
                slug = project!.commitSlug(commitMessage)
                
                let commitCommand = CommitCommand(atlasCore)

                _ = commitCommand.message.setValue(commitMessage)
                _ = commitCommand.project.setValue(projectName)
                do {
                    try commitCommand.execute()
                } catch {
                    expect(false).to(beTrue(), description: "Commit command failed")
                }
                
                commitFolder = commitUrl.appendingPathComponent(slug)
                
                purgeCommand = PurgeCommand(atlasCore)
            }
            
            afterEach {
                Helper.deleteTestDirectory(directory)
            }
            
            context("running") {

                var fileName: String!
                var relativeFilePath: String!
                
                beforeEach {
                    fileName = file1.lastPathComponent
                    relativeFilePath = "\(projectName)/committed/\(slug!)/\(fileName!)"
                    
                    purgeCommand.files.value = [relativeFilePath]
                    
                    do {
                        try purgeCommand.execute()
                    } catch {
                        expect(false).to(beTrue(), description: "Purge command failed")
                    }
                }
                
                it("should remove the file from the committed folder") {
                    let filePath = commitUrl.appendingPathComponent(fileName).path
                    let exists = fileManager.fileExists(atPath: filePath, isDirectory: &isFile)
                    expect(exists).to(beFalse(), description: "Committed file still found")
                }
                
                it("should remove the commit from the log") {
                    let log = atlasCore.log()
                    expect(log.count).to(equal(0))
                }

                it("should remove the commit folder") {
                    let exists = fileManager.fileExists(atPath: commitFolder.path, isDirectory: &isDirectory)
                    expect(exists).to(beFalse(), description: "Commit folder still found")
                }
            }
        }
    }
}




