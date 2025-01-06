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
        let packageDirectory = context.pluginWorkDirectoryURL
        
        let executablePath = try context.tool(named: "xibidgenerator").url
        print("Running executable at \(executablePath.path)")
        // Create a process to execute the file
        let process = Process()
        // Add arguments if necessary
        process.executableURL = executablePath
        let sourceDirectory = context.xcodeProject.directory

                
        print("context: Source Directory: \(sourceDirectory)")
        
        process.arguments = [sourceDirectory.string]
        
        // Capture the output
        let outputPipe = Pipe()
        process.standardError = outputPipe
        
        process.standardOutput = outputPipe
        // Run the process
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            throw PluginError.executionFailed(status: process.terminationStatus)
        }
        
        // Get the output from the process
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: outputData, encoding: .utf8) {
            print("Executable output:")
            print(output)
        }
        
        // Check for errors
        if process.terminationStatus != 0 {
            throw PluginError.executionFailed(status: process.terminationStatus)
        }
    }
    
    
}
extension XibIDGenerateCommand: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let packageDirectory = context.package.directory
        
        // Output a message
        print("Command Plugin: Running the custom plugin in \(packageDirectory.string)")
        
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

extension XibIDGenerateCommand {
    enum PluginError: Error, CustomStringConvertible {
        case executionFailed(status: Int32)
        
        var description: String {
            switch self {
            case .executionFailed(let status):
                return "Executable failed with exit code \(status)"
            }
        }
    }
}
