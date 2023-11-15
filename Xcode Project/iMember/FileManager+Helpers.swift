import Foundation

extension FileManager {
    
    func removeFileIfItExists(_ file: URL) throws {
        let filePath = file.path(percentEncoded: false)
        
        if FileManager.default.fileExists(atPath: filePath) {
            try FileManager.default.removeItem(at: file)
        }
    }
}
