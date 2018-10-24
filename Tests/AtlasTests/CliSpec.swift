//
//  CliSpec.swift
//  AtlasTests
//
//  Created by Jared Cosulich on 10/23/18.
//

import Foundation
import Quick

class CliSpec: QuickSpec {

    let githubPassword = ProcessInfo.processInfo.environment["ATLAS_GITHUB_PASSWORD"]
    
}
