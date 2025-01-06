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
struct XibIDGenerateCommand {
    
   
}

extension XibIDGenerateCommand: XcodeCommandPlugin {
    func performCommand(context: XcodeProjectPlugin.XcodePluginContext, arguments: [String]) throws {
        let packageDirectory = context.pluginWorkDirectoryURL.appending(path: "report.txt")
        
        // Output a message
        print("Running the custom plugin in \(packageDirectory)")
        
        // Generate a dummy report file
        
        let content = "This is a generated report for the package."
        
        try content.write(to: packageDirectory, atomically: true, encoding: .utf8)
        print("Report generated at \(packageDirectory)")
    
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
        
        try content.write(to: reportFile.url, atomically: true, encoding: .utf8)
        print("Report generated at \(reportFile.string)")
    }
}
extension Path {
    var url: URL {
        return URL(fileURLWithPath: self.string)
    }
}
