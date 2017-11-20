import Foundation

protocol AtlasProcess {
    func launch()
}

extension Process: AtlasProcess { }
