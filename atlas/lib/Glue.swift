//
//  Glue.swift
//  atlas
//
//  Created by Jared Cosulich on 11/19/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Foundation

struct GlueConfiguration {
    let process: Process!
    let pipe: Pipe!

//    let installed = [String: Bool]

    init(providedProcess: Process=Process(), providedPipe: Pipe=Pipe()) {
        process = providedProcess
        pipe = providedPipe
    }
}

class Glue {
    
    class func runProcess(_ command: String, arguments: [String], config: GlueConfiguration=GlueConfiguration()) -> String {
        let process = config.process!
        let pipe = config.pipe!
        process.standardOutput = pipe
        
        process.launchPath = command
        process.arguments = arguments
        
        let file:FileHandle = pipe.fileHandleForReading
        
        process.launch()
        process.waitUntilExit()
        
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
