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
struct XibIDGenerateCommand: BuildToolPlugin {
    
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        debugPrint(context)
        return [.buildCommand(displayName: "Lint Xib Identifier Code", executable: URL(fileURLWithPath: "/usr/local/bin/swiftlint"), arguments: ["lint", "--path"], inputFiles: [], outputFiles: [])]
    }
}

extension XibIDGenerateCommand: XcodeCommandPlugin, XcodeBuildToolPlugin {
    
    
    func createBuildCommands(context: XcodeProjectPlugin.XcodePluginContext, target: XcodeProjectPlugin.XcodeTarget) throws -> [PackagePlugin.Command] {
        let executablePath = try context.tool(named: "xibidgenerator").url
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
extension XibIDGenerateCommand: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let packageDirectory = context.package.directory
        
        // Output a message
        print("Running the custom plugin in \(packageDirectory.string)")
        
        // Generate a dummy report file
        let reportFile = packageDirectory.appending("report.txt")
        let content = "This is a generated report for the package."
        
//        try content.write(to: reportFile, atomically: true, encoding: .utf8)
        print("Report generated at \(reportFile.string)")
    }
}
