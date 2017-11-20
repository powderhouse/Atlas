import Foundation

protocol AtlasProcess {
    var executableURL: URL? { get set }
    var arguments: [String]? { get set }    
    func runAndWait() -> String
}

extension Process: AtlasProcess {
    func runAndWait() -> String {
        let pipe = Pipe()
        standardOutput = pipe
        
        do {
            try run()
        } catch {
            return "Error: \(error)"
        }
        waitUntilExit()
        
        let file:FileHandle = pipe.fileHandleForReading
        let data =  file.readDataToEndOfFile()
        return String(data: data, encoding: String.Encoding.utf8) as String!
    }
    
}

