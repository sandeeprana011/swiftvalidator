import Foundation
import SwiftParser
import SwiftSyntax

@main class AccessibilityValidatorModule {
    
    @MainActor static let shared = AccessibilityValidatorModule()
    
    var errors: [String] = []
    
    static func main() {
        debugPrint("Executing main function")
        
        guard CommandLine.arguments.count == 2 else {
            print("Not enough arguments!")
            return
        }
        
        
        let filePath = CommandLine.arguments[1]
        guard FileManager.default.fileExists(atPath: filePath) else {
            print("File doesn't exist at path: \(filePath)")
            return
        }
        
        
        guard let source = try? String(contentsOfFile: filePath) else {
            print("File at path isn't readable: \(filePath)")
            return
        }
        
        
        let fileInfo = FileInfo(path: filePath, source: source, delegate: shared)
        checkFile(for: fileInfo)
        if !shared.errors.isEmpty {
            shared.errors.forEach { errorString in
                print(errorString)
            }
            exit(1)
        }
        
    }
    
}

extension AccessibilityValidatorModule: DelegateValidator {
    func newError(error: String) {
        self.errors.append(error)
    }
}
