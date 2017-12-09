import Foundation

protocol AtlasProcess {
    var currentDirectoryURL: URL? { get set }
    var executableURL: URL? { get set }
    var arguments: [String]? { get set }    
    func runAndWait() -> String
}

protocol AtlasProcessFactory {
    func build() -> AtlasProcess
}

extension Process: AtlasProcess {
    func runAndWait() -> String {
        let pipe = Pipe()
        standardOutput = pipe
        
        do {
            try run()
        } catch {
            return "AtlasProcess Error: \(error)"
        }
        waitUntilExit()
        
        let file:FileHandle = pipe.fileHandleForReading
        let data =  file.readDataToEndOfFile()
        print("RESULT: \(String(data: data, encoding: String.Encoding.utf8) as String!)")
        return String(data: data, encoding: String.Encoding.utf8) as String!
    }
}

class ProcessFactory: AtlasProcessFactory {
    init() {
    }
    
    func build() -> AtlasProcess {
        return Process()
    }
}
