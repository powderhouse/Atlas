//
//  CommitCommandSpec.swift
//  AtlasTests
//
//  Created by Jared Cosulich on 3/6/18.
//


import Foundation
import Quick
import Nimble
import AtlasCore
import AtlasCommands

class CommitCommandSpec: QuickSpec {
    override func spec() {
        
        describe("Commit") {
            
            let projectName = "TestProject"
            
            var fileDirectory: URL!
            var file1: URL!
            
            var directory: URL!
            var atlasCore: AtlasCore!
            
            let fileManager = FileManager.default
            var isFile : ObjCBool = false
            var isDirectory : ObjCBool = true
            
            var commitCommand: CommitCommand!
            let commitMessage = "This it the message for the commit."
            
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
                
                commitCommand = CommitCommand(atlasCore)
            }
            
            afterEach {
                atlasCore.deleteGitHubRepository()
                FileSystem.deleteDirectory(fileDirectory)
                FileSystem.deleteDirectory(directory)
            }
            
            context("running") {
                
                var project: Project!
                var commitUrl: URL!
                var slug: String!
                var commitFolder: URL!
                
                beforeEach {
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

                }
                
                it("should move the file out of the project's staged folder") {
                    if let stagedURL = atlasCore.project(projectName)?.directory("staged") {
                        let filePath = stagedURL.appendingPathComponent(file1.lastPathComponent).path
                        let exists = fileManager.fileExists(atPath: filePath, isDirectory: &isFile)
                        expect(exists).to(beFalse(), description: "Staged file still found")
                    }
                }
                
                it("should create a folder in the commit folder with a unique slug based on the commit message") {
                    let exists = fileManager.fileExists(atPath: commitFolder.path, isDirectory: &isDirectory)
                    expect(exists).to(beTrue(), description: "Unable to find commited folder")
                }
                
                it("should include a file with the full commit message in a readme.md") {
                    let commitMessageFileUrl = commitFolder.appendingPathComponent(Project.readme)
                    let exists = fileManager.fileExists(atPath: commitMessageFileUrl.path, isDirectory: &isFile)
                    expect(exists).to(beTrue(), description: "Commit message file not found in committed directory")
                    
                    do {
                        let contents = try String(contentsOf: commitMessageFileUrl, encoding: .utf8)
                        expect(contents).to(equal(commitMessage))
                    } catch {
                        expect(false).to(beTrue(), description: "unable to load contents")
                    }
                }
                
                it("should include all files that were in the staging directory") {
                    let committedFilePath = commitFolder.appendingPathComponent(file1.lastPathComponent).path
                    let exists = fileManager.fileExists(atPath: committedFilePath, isDirectory: &isFile)
                    expect(exists).to(beTrue(), description: "File not found in committed directory")
                }
                
                it("should sync with github") {
                    expect(atlasCore.status()).to(contain("nothing to commit"))
                }
            }
            
            context("running with no message provided") {
                
                var project: Project!
                var commitUrl: URL!
                var slug: String!
                var commitFolder: URL!
                
                beforeEach {
                    _ = commitCommand.project.setValue(projectName)
                    
                    project = atlasCore.project(projectName)
                    
                    guard project != nil else  {
                        expect(false).to(beTrue(), description: "Project not found")
                        return
                    }
                    
                    commitUrl = project!.directory("committed")
                    slug = project!.commitSlug(commitMessage)
                    commitFolder = commitUrl.appendingPathComponent(slug)
                    
                }
                
                it("should do nothing if no commit message has already been created") {
                    do {
                        try commitCommand.execute()
                    } catch {
                        expect(false).to(beTrue(), description: "Commit command failed")
                    }

                    let exists = fileManager.fileExists(atPath: commitFolder.path, isDirectory: &isDirectory)
                    expect(exists).to(beFalse(), description: "Found commited folder")
                }
                
                it("should create the commit folder and move the committed.txt into it if a commit message has been added (rename it to readme.me)") {
                    let commitFile = project.directory().appendingPathComponent(Project.commitMessageFile)
                    do {
                        try commitMessage.write(to: commitFile, atomically: true, encoding: .utf8)
                    } catch {
                        expect(false).to(beTrue(), description: "Failed to write commit message file")
                    }
                    
                    do {
                        try commitCommand.execute()
                    } catch {
                        expect(false).to(beTrue(), description: "Commit command failed")
                    }
                    
                    let exists = fileManager.fileExists(atPath: commitFolder.path, isDirectory: &isDirectory)
                    expect(exists).to(beTrue(), description: "Did not find commited folder")

                    let committedFile = commitFolder.appendingPathComponent(Project.readme)
                    let fileExists = fileManager.fileExists(atPath: committedFile.path, isDirectory: &isFile)
                    expect(fileExists).to(beTrue(), description: "Did not find committed commit message file")
                }
            }
        }
    }
}
