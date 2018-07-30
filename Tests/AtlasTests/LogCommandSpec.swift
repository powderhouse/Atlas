//
//  LogCommandSpec.swift
//  AtlasTests
//
//  Created by Jared Cosulich on 3/9/18.
//

import Foundation
import Quick
import Nimble
import AtlasCore
import AtlasCommands

class LogCommandSpec: QuickSpec {
    
    var output = ""
    let inputPipe = Pipe()
    let outputPipe = Pipe()
    
    func handlePipeNotification(notification: Notification) {
        //note you have to continuously call this when you get a message
        //see this from documentation:
        //Note that this method does not cause a continuous stream of notifications to be sent. If you wish to keep getting notified, you’ll also need to call readInBackgroundAndNotify() in your observer method.
        inputPipe.fileHandleForReading.readInBackgroundAndNotify()
        
        if let data = notification.userInfo?[NSFileHandleNotificationDataItem] as? Data,
            let str = String(data: data, encoding: String.Encoding.ascii) {
            
            
            //write the data back into the output pipe. the output pipe's write file descriptor points to STDOUT. this allows the logs to show up on the xcode console
            outputPipe.fileHandleForWriting.write(data)
            
            output.append(str)
            // `str` here is the log/contents of the print statement
            //if you would like to route your print statements to the UI: make
            //sure to subscribe to this notification in your VC and update the UITextView.
            //Or if you wanted to send your print statements to the server, then
            //you could do this in your notification handler in the app delegate.
        }
    }

    override func spec() {
        
        describe("Log") {
            let projectName1 = "General"
            let projectName2 = "TestProject"

            var fileDirectory: URL!

            let file1 = "index1.html"
            let file2 = "index2.html"
            let message1 = "Commit Message 1"
            let message2 = "Commit Message 2"

            var directory: URL!
            var atlasCore: AtlasCore!
            
            beforeEach {
                let temp = URL(fileURLWithPath: NSTemporaryDirectory())
                fileDirectory = temp.appendingPathComponent("FILE_DIRECTORY")
                directory = temp.appendingPathComponent("ATLAS_CORE")
                
                FileSystem.createDirectory(fileDirectory)
                FileSystem.createDirectory(directory)
                
                let file1Url = Helper.addFile(file1, directory: fileDirectory)
                let file2Url = Helper.addFile(file2, directory: fileDirectory)

                atlasCore = AtlasCore(directory)
                expect(Helper.initAtlasCore(atlasCore)).to(beTrue())
                _ = atlasCore.initProject(projectName2)
                
                let importCommand1 = ImportCommand(atlasCore)
                importCommand1.imports.value = [file1Url.path]
                let importCommand2 = ImportCommand(atlasCore)
                importCommand2.imports.value = [file2Url.path]
                if !importCommand1.project.setValue(projectName1) || !importCommand2.project.setValue(projectName2) {
                    expect(false).to(beTrue(), description: "Failed to set project key value")
                }
                do {
                    try importCommand1.execute()
                    try importCommand2.execute()
                } catch {
                    expect(false).to(beTrue(), description: "Import command failed")
                }
                
                let commitCommand1 = CommitCommand(atlasCore)
                _ = commitCommand1.message.setValue(message1)
                _ = commitCommand1.project.setValue(projectName1)
                let commitCommand2 = CommitCommand(atlasCore)
                _ = commitCommand2.message.setValue(message2)
                _ = commitCommand2.project.setValue(projectName2)
                do {
                    try commitCommand1.execute()
                    try commitCommand2.execute()
                } catch {
                    expect(false).to(beTrue(), description: "Commit command failed")
                }
            }
            
            afterEach {
                Helper.deleteTestDirectory(directory)
            }
            
            context("running") {
                
                beforeEach {
                    let pipeReadHandle = self.inputPipe.fileHandleForReading

                    dup2(STDOUT_FILENO, self.outputPipe.fileHandleForWriting.fileDescriptor)
                    dup2(self.inputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
                    
                    //listen in to the readHandle notification
                    NotificationCenter.default.addObserver(self, selector: #selector(self.handlePipeNotification), name: FileHandle.readCompletionNotification, object: pipeReadHandle)
                    
//                    state that you want to be notified of any data coming across the pipe
                    pipeReadHandle.readInBackgroundAndNotify()

                    let logCommand = LogCommand(atlasCore)
                    _ = logCommand.project.setValue(projectName1)
                    do {
                       
                        try logCommand.execute()
                    } catch {
                        expect(false).to(beTrue(), description: "Log command failed")
                    }
                }
                
                afterEach {
                    dup2(STDOUT_FILENO, self.inputPipe.fileHandleForWriting.fileDescriptor)
                }
                
                it("should display a log of commits") {
                    expect(self.output).toEventually(contain(message1), timeout: 30)
                    expect(self.output).toEventually(contain(file1), timeout: 30)
                    expect(self.output).toNot(contain(message2))
                }
                
            }
        }
    }
}
