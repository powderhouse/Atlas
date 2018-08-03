//
//  ImportCommandSpec
//  AtlasTests
//
//  Created by Jared Cosulich on 2/26/18.
//


import Foundation
import Quick
import Nimble
import AtlasCore
import AtlasCommands

class ImportCommandSpec: QuickSpec {
    override func spec() {
        
        describe("Import") {
            
            let projectName = "TestProject"
            
            var fileDirectory: URL!
            var file1: URL!
            var file2: URL!

            var directory: URL!
            var atlasCore: AtlasCore!
            
            var importCommand: ImportCommand!
            
            let fileManager = FileManager.default
            var isFile : ObjCBool = false
            
            beforeEach {
                let temp = URL(fileURLWithPath: NSTemporaryDirectory())
                fileDirectory = temp.appendingPathComponent("FILE_DIRECTORY")
                directory = temp.appendingPathComponent("ATLAS_CORE")
                
                Helper.deleteTestDirectory(directory)

                FileSystem.createDirectory(fileDirectory)
                FileSystem.createDirectory(directory)
                
                file1 = Helper.addFile("index1.html", directory: fileDirectory)
                file2 = Helper.addFile("index2.html", directory: fileDirectory)

                atlasCore = AtlasCore(directory)
                expect(Helper.initAtlasCore(atlasCore)).to(beTrue())
                _ = atlasCore.initProject(projectName)
                
                importCommand = ImportCommand(atlasCore)
            }
            
            afterEach {
                Helper.deleteTestDirectory(directory)
            }
            
            
            context("running") {
                
                beforeEach {
                    importCommand.imports.value = [file1.path, file2.path]
                    if !importCommand.project.setValue(projectName) {
                        expect(false).to(beTrue(), description: "Failed to set project key value")
                    }
                    do {
                        try importCommand.execute()
                    } catch {
                        expect(false).to(beTrue(), description: "Import command failed")
                    }
                }
                
                it("should copy both files into the project's staging folder") {
                    for file in [file1, file2] {
                        if let fileName = file?.lastPathComponent {
                            if let projectURL = atlasCore.project(projectName)?.directory("staged") {
                                let filePath = projectURL.appendingPathComponent(fileName).path
                                let exists = fileManager.fileExists(atPath: filePath, isDirectory: &isFile)
                                expect(exists).to(beTrue(), description: "File not found")
                            }
                        }
                    }
                }

                it("should leave both files in the original folder") {
                    for file in [file1, file2] {
                        let exists = fileManager.fileExists(atPath: file!.path, isDirectory: &isFile)
                        expect(exists).to(beTrue(), description: "Original file not found")
                    }
                }

                it("should sync with github") {
                    expect(atlasCore.status()).to(contain("nothing to commit"))
                }

            }
        }
    }
}



