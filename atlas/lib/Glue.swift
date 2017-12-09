//
//  Glue.swift
//  atlas
//
//  Created by Jared Cosulich on 11/19/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//




// THIS IS A WORK IN PROGRESS






import Foundation
import AppKit

class Glue {
    
    static let installCommands = [
        "homebrew": "/usr/bin/ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\""
    ]
    
    class func runProcess(_ command: String, arguments: [String]?=[], currentDirectory: URL?=nil, atlasProcess: AtlasProcess=Process()) -> String {
        var process = atlasProcess
        
        print("URL: \(command) \((arguments ?? []).joined(separator: " "))")
        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = arguments
        if currentDirectory != nil {
            process.currentDirectoryURL = currentDirectory
        }

        return process.runAndWait()
    }
    
    class func installHomebrew(find: AtlasProcess=Process(), install: AtlasProcess=Process()) {
//        NSWorkspace.shared.launchApplication("brew")
        
//        let fileManager = FileManager.default
//        let url = URL(fileURLWithPath: "/usr/bin/python")
//        print("EXISTS: \(fileManager.fileExists(atPath: url.path))")
//        do {
//            try print(fileManager.destinationOfSymbolicLink(atPath: url.path))
//        } catch {
//            print("ERROR: \(error)")
//        }
//        destinationOfSymbolicLink(atPath path: String) throws -> String
//
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/git")
//        p.executableURL = FileSystem.accountDirectory()?.appendingPathComponent("./test.sh")
//        p.executableURL = URL(fileURLWithPath: "/usr/bin/syslog")
        p.arguments = ["--git-dir=/Users/jcosulich/workspace/atlas/.git", "status"]

        let pipe = Pipe()
        p.standardOutput = pipe

        do {
            try p.run()
        } catch {
            print("Error: \(error)")
        }
        p.waitUntilExit()

        let file:FileHandle = pipe.fileHandleForReading
        let data =  file.readDataToEndOfFile()
        print(String(data: data, encoding: String.Encoding.utf8) as String!)


////        let findOutput = runProcess("locate", arguments: ["Homebrew"], atlasProcess: find)
////        print(findOutput)
////        if findOutput == "" {
////            _ = runProcess(installCommands["homebrew"]!, atlasProcess: install)
////        }
    }
    
    class func installS3() {
//        print(Glue.run("/bin/bash", arguments: ["-c", "ls"]))
//        installHomebrew()
    }
    
    
}
