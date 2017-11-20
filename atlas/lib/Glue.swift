//
//  Glue.swift
//  atlas
//
//  Created by Jared Cosulich on 11/19/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Foundation

struct GlueConfiguration {
    let process: AtlasProcess!
    let pipe: Pipe!

//    let installed = [String: Bool]

    init(atlasProcess: AtlasProcess=Process(), providedPipe: Pipe=Pipe()) {
        process = atlasProcess
        pipe = providedPipe
    }
}

class Glue {
    
    class func runProcess(_ command: String, arguments: [String], config: GlueConfiguration=GlueConfiguration()) -> String {
        var process = config.process!
        let pipe = config.pipe!

        process.executableURL = NSURL(fileURLWithPath: command).absoluteURL
        process.arguments = arguments
        process.standardOutput = pipe

        do {
            try process.run()
        } catch {
            return "Error: \(error)"
        }
        
        process.waitUntilExit()

        let file:FileHandle = pipe.fileHandleForReading
        let data =  file.readDataToEndOfFile()
        return String(data: data, encoding: String.Encoding.utf8) as String!
    }
    
    class func installHomebrew() {
        ///usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    }
    
    class func installS3() {
//        print(Glue.run("/bin/bash", arguments: ["-c", "ls"]))
        installHomebrew()
    }
    
    
}
