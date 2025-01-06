//
//  File.swift
//  swiftvalidator
//
//  Created by Sandeep Rana on 29/12/24.
//


import PackagePlugin
import Foundation
import XcodeProjectPlugin


@main
struct XibAccessibilityIdentifierUpdater: BuildToolPlugin {
    
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        debugPrint(context)
        return [.buildCommand(displayName: "Lint Xib Identifier Code", executable: URL(fileURLWithPath: "/usr/local/bin/swiftlint"), arguments: ["lint", "--path"], inputFiles: [], outputFiles: [])]
    }
}

extension XibAccessibilityIdentifierUpdater: XcodeCommandPlugin, XcodeBuildToolPlugin {
    
    
    func createBuildCommands(context: XcodeProjectPlugin.XcodePluginContext, target: XcodeProjectPlugin.XcodeTarget) throws -> [PackagePlugin.Command] {
        let executablePath = try context.tool(named: "xibidlint").url
        debugPrint("swiftvalidator path: \(executablePath)")
        
        var commands = [Command]()
        
        target.inputFiles.filter({ file in
            file.url.path().hasSuffix(".xib") || file.url.path().hasSuffix(".storyboard")
        }).forEach { file in
            let pathFile: String = file.url.path()
            commands.append(Command.buildCommand(displayName: "Lint Xib Identifier Code Xcode", executable:  executablePath, arguments: [pathFile], inputFiles: [], outputFiles: []))
        }
        
        
        return commands
    }
    
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        debugPrint(context)
        print("Running xcode command")
    }
    
}
