import Foundation

protocol AtlasProcess {
    var executableURL: URL? { get set }
    var arguments: [String]? { get set }
    var standardOutput: Any? { get set }
    
    func run() throws
    func waitUntilExit()
    
}

extension Process: AtlasProcess { }

