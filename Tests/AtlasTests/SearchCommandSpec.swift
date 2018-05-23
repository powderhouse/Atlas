//
//  SearchCommandSpec.swift
//  AtlasTests
//
//  Created by Jared Cosulich on 5/22/18.
//

import Foundation
import Quick
import Nimble
import AtlasCore
import AtlasCommands

class SearchCommandSpec: QuickSpec {
    
    var output = ""
    let inputPipe = Pipe()
    let outputPipe = Pipe()
    
    func handlePipeNotification(notification: Notification) {
        inputPipe.fileHandleForReading.readInBackgroundAndNotify()
        
        if let data = notification.userInfo?[NSFileHandleNotificationDataItem] as? Data,
            let str = String(data: data, encoding: String.Encoding.ascii) {
            
            outputPipe.fileHandleForWriting.write(data)
            
            output.append(str)
        }
    }
    
    override func spec() {
        
        describe("Search") {
            
            let projectName = "TestProject"
            
            var fileDirectory: URL!
            var file1: URL!
            
            var directory: URL!
            var atlasCore: AtlasCore!
            
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
                
                let commitCommand = CommitCommand(atlasCore)
                _ = commitCommand.message.setValue(commitMessage)
                _ = commitCommand.project.setValue(projectName)
                
                do {
                    try commitCommand.execute()
                } catch {
                    expect(false).to(beTrue(), description: "Commit command failed")
                }            }
            
            afterEach {
                atlasCore.closeSearch()
                atlasCore.deleteGitHubRepository()
                FileSystem.deleteDirectory(fileDirectory)
                FileSystem.deleteDirectory(directory)
            }
            
            context("running") {
                
                let searchTerms = ["message", "for"]
                
                beforeEach {
                    let pipeReadHandle = self.inputPipe.fileHandleForReading
                    
                    dup2(STDOUT_FILENO, self.outputPipe.fileHandleForWriting.fileDescriptor)
                    dup2(self.inputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
                    
                    //listen in to the readHandle notification
                    NotificationCenter.default.addObserver(self, selector: #selector(self.handlePipeNotification), name: FileHandle.readCompletionNotification, object: pipeReadHandle)
                    
                    // state that you want to be notified of any data coming across the pipe
                    pipeReadHandle.readInBackgroundAndNotify()
                    
                    let searchCommand = SearchCommand(atlasCore)
                    searchCommand.terms.value = searchTerms
                    
                    do {
                        try searchCommand.execute()
                    } catch {
                        expect(false).to(beTrue(), description: "Search command failed")
                    }
                }
                
                afterEach {
                    dup2(STDOUT_FILENO, self.inputPipe.fileHandleForWriting.fileDescriptor)
                }
                
                it("should move the file out of the project's staged folder") {
                    expect(self.output).toEventually(contain("readme"), timeout: 30)
                    expect(self.output).toNot(contain("index"))
                }
            }
        }
    }
}
