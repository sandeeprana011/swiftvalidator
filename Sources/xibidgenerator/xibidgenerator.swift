//
//  File.swift
//  swiftvalidator
//
//  Created by Sandeep Rana on 29/12/24.
//

import Foundation

@main class xibidgenerator {
    
    @MainActor static let shared = xibidgenerator()
    
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
        
        shared.processDirectory(filePath)
        
    }
    
    func processFile(atPath path: String) {
        guard let xmlData = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            debugPrint("\(#file):1: error:Failed to read file: \(path)")
            exit(1) // Exit with error status to indicate a problem
            return
        }
        debugPrint("Processing file \(path)")
        do {
            
            let document = try XMLDocument(data: xmlData, options: .nodePreserveAll)
            
            let fileName = path.split(separator: "/").last?.split(separator: ".").first
            
            let connections = try? getAllConnections(xmlDocument: document)
            
            debugPrint("FileName: ", fileName, path, path.split(separator: "/"))

            updateAccessibilityIdentifiers(in: document.rootElement(), connections: connections ?? [:], customClass: String(fileName ?? ""))


            let updatedXMLData = document.xmlData(options: .nodePrettyPrint)

            try updatedXMLData.write(to: URL(fileURLWithPath: path))

//            debugPrint("Updated file: \(path)")
        } catch let error {
            debugPrint("\(#file):1: error: Failed to write file: \(error)")
            exit(1)
        }
    }
    
    private func getAllConnections(xmlDocument: XMLDocument) throws -> [String: String] {
        // XPath query to find all `outlet` elements within `connections`
        let outlets = try xmlDocument.nodes(forXPath: "//connections/outlet")
        
        var connectionsMap = [String: String]()
        // Iterate through the outlets and extract attributes
        for outlet in outlets {
            if let element = outlet as? XMLElement {
                let property = element.attribute(forName: "property")?.stringValue ?? "N/A"
                let destination = element.attribute(forName: "destination")?.stringValue ?? "N/A"
                let id = element.attribute(forName: "id")?.stringValue ?? "N/A"
                
                connectionsMap[destination] = property
                
                debugPrint("Outlet - Property: \(property), Destination: \(destination), ID: \(id)")
            }
        }
        
        return connectionsMap
    }

    /// Recursively update accessibility identifiers for relevant elements
    private func updateAccessibilityIdentifiers(in element: XMLElement?, connections: [String: String], customClass: String? = nil) {
        guard let element = element else { return }
        
        
        let customClassPlaceholder = "\(customClass != nil ? "\(customClass ?? "")_" : "")"
        debugPrint("Custom Class: ", customClassPlaceholder, customClass)
        
        if let tagName = Tags(rawValue: element.name ?? "")  {
            let identifier = element.attribute(forName: "id")?.stringValue
//            debugPrint("Going through Tag Name: ", connections, identifier)
            if element.children?.filter({element in element.name == "accessibility"}).first == nil {
                let accessibilityElement = XMLElement(name: "accessibility")
                accessibilityElement.addAttribute(XMLNode.attribute(withName: "key", stringValue: "accessibilityConfiguration") as! XMLNode)
                accessibilityElement.addAttribute(XMLNode.attribute(withName: "identifier", stringValue: "\(customClassPlaceholder)\(tagName.rawValue)_\(connections[identifier ?? ""] ?? "")") as! XMLNode)
                element.addChild(accessibilityElement)
//                print("Child Node: ",accessibilityElement)
            }
//            debugPrint(element.children)
        } else {
//            print("Element not found", element.name)
        }

        // Recursively process child elements
        for child in element.children ?? [] {
            updateAccessibilityIdentifiers(in: child as? XMLElement, connections: connections, customClass: customClass)
        }
    }

    /// Recursively process all XIB and Storyboard files in a directory
    func processDirectory(_ directory: String) {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(atPath: directory) else {
            print("Failed to access directory: \(directory)")
            return
        }

        for case let file as String in enumerator {
            if file.hasSuffix(".xib") || file.hasSuffix(".storyboard") {
                let fullPath = (directory as NSString).appendingPathComponent(file)
                processFile(atPath: fullPath)
            }
        }
    }
    
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
