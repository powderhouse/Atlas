//
//  AtlasInput.swift
//  Atlas
//
//  Created by Jared Cosulich on 3/1/18.
//

import Cocoa
import SwiftCLI

class AtlasInput {
    
    var defaultInputs: [String: String] = [:]
    
    init() {}
    
    func awaitInput(message: String, secure:Bool=false) -> String {
        if let response = defaultInputs[message] {
            return response
        }
        
        return Input.awaitInput(message: message, secure: secure)
    }
    
    func awaitYesNoInput(message: String) -> Bool {
        print("AWAIT YES/NO: \(message)")
        
        if let response = defaultInputs[message] {
            return response.lowercased() == "y" || response.lowercased() == "yes"
        }
        
        return Input.awaitYesNoInput(message: message)
    }
    
    func setDefaultInput(message: String, response: String) {
        defaultInputs[message] = response
    }
    
}
