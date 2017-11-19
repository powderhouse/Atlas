//
//  Glue.swift
//  atlas
//
//  Created by Jared Cosulich on 11/19/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Foundation

class Glue {
    
    class func runProcess(_ command: String, arguments: [String]) -> String {
        let process = Process()
        let pipe = Pipe()
        process.standardOutput = pipe
        
        process.launchPath = command
        process.arguments = arguments
        
        let file:FileHandle = pipe.fileHandleForReading
        
        process.launch()
        process.waitUntilExit()
        
        let data =  file.readDataToEndOfFile()
        return String(data: data, encoding: String.Encoding.utf8) as String!
    }
    
    class func installS3() {
//        print(Glue.run("/bin/bash", arguments: ["-c", "ls"]))
    }
    
    
}
