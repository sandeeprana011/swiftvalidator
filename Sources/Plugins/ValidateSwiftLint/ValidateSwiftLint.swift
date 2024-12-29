//
//  File.swift
//  swiftvalidator
//
//  Created by Sandeep Rana on 27/12/24.
//

import PackagePlugin
import Foundation
import XcodeProjectPlugin

@main
struct ValidateSwiftLint: BuildToolPlugin {
    
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        debugPrint(context)
        return [.buildCommand(displayName: "Lint Swift Code", executable: URL(fileURLWithPath: "/usr/local/bin/swiftlint"), arguments: ["lint", "--path"], inputFiles: [], outputFiles: [])]
    }
}

extension ValidateSwiftLint: XcodeCommandPlugin, XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodeProjectPlugin.XcodePluginContext, target: XcodeProjectPlugin.XcodeTarget) throws -> [PackagePlugin.Command] {
        let executablePath = try context.tool(named: "swiftvalidator").url
        debugPrint("swiftvalidator path: \(executablePath)")
        
        var commands = [Command]()
        
        target.inputFiles.forEach { file in
//            debugPrint("File Urls: ", file.url.standardizedFileURL.path())
            let pathFile: String = file.url.path()
            commands.append(Command.buildCommand(displayName: "Lint Swift Code Xcode", executable:  executablePath, arguments: [pathFile], inputFiles: [], outputFiles: []))
        }
        
        
        return commands
    }
    
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        debugPrint(context)
        print("Running xcode command")
    }
    
}
