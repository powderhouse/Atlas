//
//  ProjectsCommandSpec.swift
//  AtlasTests
//
//  Created by Jared Cosulich on 3/6/18.
//

import Foundation
import Quick
import Nimble
import AtlasCore
import AtlasCommands

class ProjectsCommandSpec: CliSpec {
    
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
        
        describe("Projects") {
            var directory: URL!
            var atlasCore: AtlasCore!
            
            var projectsCommand: ProjectsCommand!
            
            let projectName1 = "Test Project 1"
            let projectName2 = "Test Project 2"

            beforeEach {
                let temp = URL(fileURLWithPath: NSTemporaryDirectory())
                directory = temp.appendingPathComponent("ATLAS_CORE")

                Helper.deleteTestDirectory(directory)
                _ = FileSystem.createDirectory(directory)
                
                atlasCore = AtlasCore(directory)
                expect(Helper.initAtlasCore(atlasCore)).to(beTrue())
                
                let startProjectCommand1 = StartProjectCommand(atlasCore)
                let startProjectCommand2 = StartProjectCommand(atlasCore)
                
                startProjectCommand1.project.update(value: projectName1)
                startProjectCommand2.project.update(value: projectName2)
                
                do {
                    try startProjectCommand1.execute()
                    try startProjectCommand2.execute()
                } catch {
                    expect(false).to(beTrue(), description: "Start project command failed")
                }
                
                projectsCommand = ProjectsCommand(atlasCore)
            }
            
            afterEach {
                Helper.deleteTestDirectory(directory)
            }
            
            
            context("running") {
                
                beforeEach {
                    let pipeReadHandle = self.inputPipe.fileHandleForReading
                    
                    dup2(STDOUT_FILENO, self.outputPipe.fileHandleForWriting.fileDescriptor)
                    dup2(self.inputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
                    
                    // listen in to the readHandle notification
                    NotificationCenter.default.addObserver(self, selector: #selector(self.handlePipeNotification), name: FileHandle.readCompletionNotification, object: pipeReadHandle)
                    
                    // state that you want to be notified of any data coming across the pipe
                    pipeReadHandle.readInBackgroundAndNotify()
                    
                    do {
                        try projectsCommand.execute()
                    } catch {
                        expect(false).to(beTrue(), description: "Projects command failed")
                    }
                }
                
                afterEach {
                    dup2(STDOUT_FILENO, self.inputPipe.fileHandleForWriting.fileDescriptor)
                }
                
                it("should list all projects") {
                    expect(self.output).toEventually(contain("Atlas Projects:"), timeout: 30)
                    expect(self.output).toEventually(contain(projectName1), timeout: 30)
                    expect(self.output).toEventually(contain(projectName2), timeout: 30)
                }
            }
        }
    }
}


