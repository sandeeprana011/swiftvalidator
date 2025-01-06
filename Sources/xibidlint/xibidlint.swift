//
//  File.swift
//  swiftvalidator
//
//  Created by Sandeep Rana on 29/12/24.
//

import Foundation

@main class xibidlint {
    
    @MainActor static let shared = xibidlint()
    
    static func main() {
        debugPrint("Executing main function \(#file)")
        
        guard CommandLine.arguments.count == 2 else {
            print("Not enough arguments!")
            return
        }
        
        
        let filePath = CommandLine.arguments[1]
        guard FileManager.default.fileExists(atPath: filePath) else {
            print("File doesn't exist at path: \(filePath)")
            return
        }
        
        debugPrint("CommandLine Arguments: \(CommandLine.arguments)")
        
        shared.processFile(atPath: filePath)
        
    }
    
    func processFile(atPath path: String) {
        guard let xmlData = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            debugPrint("\(#file):1: error:Failed to read file: \(path)")
            exit(1) // Exit with error status to indicate a problem
            return
        }
        
        debugPrint("Processing file \(path)")

        do {
            // Parse the XML document
//            debugPrint("Reading XML")
            let document = try XMLDocument(data: xmlData, options: .nodePreserveAll)

            // Update accessibility identifiers
            updateAccessibilityIdentifiers(in: document.rootElement())

            // Write the updated XML back to the file
//            debugPrint("Writing Xml")
            let updatedXMLData = document.xmlData(options: .nodePrettyPrint)
            debugPrint("Please run Accessibility Id Generator. Found elements without any ids")
//            exit(1)
//            try updatedXMLData.write(to: URL(fileURLWithPath: path))
//            let sampleString = "sample data"
//            debugPrint(sampleString)
//            try sampleString.write(to: URL(fileURLWithPath: path), atomically: false, encoding: .utf8)
            
            debugPrint("Updated file: \(path)")
        } catch let error {
            debugPrint("\(#file):1: error: Failed to write file: \(error)")
            exit(1)
        }
    }

    /// Recursively update accessibility identifiers for relevant elements
    private func updateAccessibilityIdentifiers(in element: XMLElement?) {
        guard let element = element else { return }

        // Check if the element is in the list of supported tags
        if let tagName = Tags(rawValue: element.name ?? "")  {
            debugPrint("Problematic Tag Name: ", tagName)
            if element.children?.filter({element in element.name == "accessibility"}).first == nil {
                debugPrint("📕 📕 📕 📕 📕 📕 📕 📕 📕 📕 📕 📕")
                debugPrint("error: Please run Accessibility Id Generator. Found elements without any ids")
                debugPrint("📕 📕 📕 📕 📕 📕 📕 📕 📕 📕 📕 📕 ")
                exit(1)
            }
        }

        // Recursively process child elements
        for child in element.children ?? [] {
            updateAccessibilityIdentifiers(in: child as? XMLElement)
        }
    }

    /// Recursively process all XIB and Storyboard files in a directory
//    func processDirectory(_ directory: String) {
//        let fileManager = FileManager.default
//        guard let enumerator = fileManager.enumerator(atPath: directory) else {
//            print("Failed to access directory: \(directory)")
//            return
//        }
//
//        for case let file as String in enumerator {
//            if file.hasSuffix(".xib") || file.hasSuffix(".storyboard") {
//                let fullPath = (directory as NSString).appendingPathComponent(file)
//                processFile(atPath: fullPath)
//            }
//        }
//    }
    
//    func updateNodes() {
//        let arguments = CommandLine.arguments
//        guard arguments.count > 1 else {
//            print("Usage: XibAccessibilityTool <directory_path>")
//            return
//        }
//        let directoryPath = arguments[1]
//        let updater = xibidgenerator()
//        updater.processDirectory(directoryPath)
//    }


}

// MARK: - Supported Tags
enum Tags: String {
    case view = "view",
         label = "label",
         button = "button",
         imageView = "imageView",
         textField = "textField",
         textView = "textView",
         switchTag = "switch",
         slider = "slider",
         segmentedControl = "segmentedControl"
//         stackView = "stackView",
//         tableView = "tableView",
//         tableViewCell = "tableViewCell",
//         collectionView = "collectionView",
//         collectionViewCell = "collectionViewCell",
//         navigationBar = "navigationBar",
//         toolbar = "toolbar",
//         tabBar = "tabBar"
}
