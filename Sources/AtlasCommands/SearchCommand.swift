//
//  SearchCommand.swift
//  Atlas
//
//  Created by Jared Cosulich on 5/23/18.
//

import Cocoa
import SwiftCLI
import AtlasCore

public class SearchCommand: Command {
    
    // Atlas purge {files}
    
    public var atlasCore: AtlasCore
    public var search: Search?
    
    public let name = "search"
    public let shortDescription = "Search existing commits"
    
    public let terms = CollectedParameter()
    
    public init(_ atlasCore: AtlasCore) {
        self.atlasCore = atlasCore
        if atlasCore.initSearch() {
            search = atlasCore.search
        }
    }
    
    public func execute() throws  {
        if let results = search?.search(terms.value.joined(separator: " ")) {
            if results.count > 0 {
                for result in results {
                    print(result)
                }
            } else {
                print("No results found.")
            }
        } else {
            print("Search failed due to inproper initialization.")
        }
    }
}

