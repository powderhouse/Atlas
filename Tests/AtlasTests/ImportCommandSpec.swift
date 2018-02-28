//
//  AtlasTests.swift
//  AtlasTests
//
//  Created by Jared Cosulich on 2/26/18.
//


import Foundation
import Quick
import Nimble
import AtlasCore
import Atlas

class ImportCommandSpec: QuickSpec {
    override func spec() {
        
        describe("Import") {
            
            var directory: URL!
            var atlasCore: AtlasCore!
            
            var importCommand: ImportCommand!
            
            beforeEach {
                directory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("ATLAS_CORE")
                
                FileSystem.createDirectory(directory)
                
                //                let filePath = directory.path
                //                let exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory)
                //                expect(exists).to(beTrue(), description: "No folder found")
                
                atlasCore = AtlasCore(directory)
                importCommand = ImportCommand(atlasCore)
            }
            
            afterEach {
                FileSystem.deleteDirectory(directory)
            }
            
            
            context("running") {
                
                it("should work") {
                    print("HI: \(importCommand)")
                    expect(true).to(beTrue())
                }
            }
        }
    }
}



