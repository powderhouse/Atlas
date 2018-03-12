//
//  AtlasInput.swift
//  Atlas
//
//  Created by Jared Cosulich on 3/1/18.
//

import Cocoa
import SwiftCLI

public class AtlasInput {
    
    public var defaultInputs: [String: String] = [:]
    
    public init() {}
    
    public func awaitInput(message: String, secure:Bool=false) -> String {
        if let response = defaultInputs[message] {
            return response
        }
        
        return Input.awaitInput(message: message, secure: secure)
    }
    
    public func awaitYesNoInput(message: String) -> Bool {
        print("AWAIT YES/NO: \(message)")
        
        if let response = defaultInputs[message] {
            return response.lowercased() == "y" || response.lowercased() == "yes"
        }
        
        return Input.awaitYesNoInput(message: message)
    }
    
    public func setDefaultInput(message: String, response: String) {
        defaultInputs[message] = response
    }
    
}
