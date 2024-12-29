//
//  File.swift
//  swiftvalidator
//
//  Created by Sandeep Rana on 24/12/24.
//

import Foundation
import SwiftSyntax
import SwiftParser

protocol DelegateValidator {
    func newError(error: String)
}

struct FileInfo {
    let path: String
    let source: String
    var delegate: DelegateValidator?
}

class AccessibilityChecker: SyntaxVisitor {
    
    private let fileInfo: FileInfo
    
    init(fileInfo: FileInfo, viewMode: SyntaxTreeViewMode) {
        self.fileInfo = fileInfo
        super.init(viewMode: viewMode)
    }
    
    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        let nodeName = node.trimmed.firstToken(viewMode: .all)?.text
//        print("Custom Nodes: ", nodeName, node)
        switch nodeName {
        case "Text", "Image", "Button":
            if !"\(node)".contains("accessibility(identifi") {
                
                let line = getLine(node: node)
                
                print("Line No: ", line)
                
                let errorString = "\(self.fileInfo.path):\(line): error: accessibility(identifier: \"identifier\") must be called. e.g Text(\"myLabel\").accessibility(identifier: \"myText\") \(node)"
                self.fileInfo.delegate?.newError(error: errorString)
            }
        case "UILabel", "UIButton", "UIImageView":
            print("Working on Node: \(nodeName!)")
            print("Node config \(node.arguments), \(node.calledExpression), \(node.nextToken)")
            if !"\(node)".contains("setAccessibilityIdentifier(") {
                let line = getLine(node: node)
                print("Line No: ", line)
                
                let errorString = "\(self.fileInfo.path):\(line): error: setAccessiblityIdentifier must be called. e.g UILabel().setAccessibilityIdentifier(\"myLabel\") \(node)"
                self.fileInfo.delegate?.newError(error: errorString)
            }
        default:
            break // node not of interest
        }
        
        return .skipChildren
    }
    
    func getLine(node: FunctionCallExprSyntax) -> Int {
        return fileInfo.source.prefix(node.endPosition.utf8Offset).filter { char in
            char == "\n"
        }.count + 1
    }
    
    
    override func visitPost(_ node: FunctionCallExprSyntax) {
            if let calledExpression = node.calledExpression.as(DeclReferenceExprSyntax.self),
               calledExpression.baseName.text == "Text" {

                var hasAccessibility = false
                var currentExpression: FunctionCallExprSyntax? = node

                // Check if `accessibility` is applied in the method chain
                while let functionCall = currentExpression?.as(FunctionCallExprSyntax.self) {
                    if functionCall.calledExpression.description.contains("accessibility") {
                        hasAccessibility = true
                    }
                        break
                    currentExpression = functionCall.calledExpression.as(FunctionCallExprSyntax.self)
                }

//                if hasAccessibility {
//                    print("Text node has accessibility")
//                } else {
//                    print("Text node requires accessibility")
//                }
            }
        }
}



func checkFile(for fileInfo:FileInfo) {
    do {
        let sourceFile = try Parser.parse(source: fileInfo.source)
        let checker = AccessibilityChecker(fileInfo: fileInfo, viewMode: .all)
        checker.walk(sourceFile)
    } catch {
        print("Error parsing file: \(error)")
    }
}
