//
//  plugin.swift
//  
//
//  Created by p-x9 on 2023/03/21.
//

import Foundation
import PackagePlugin

@main
struct RunScriptCommandPlugin: CommandPlugin {
    func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
        try performCommand(
            packageDirectory: context.package.directory,
            tool: try context.tool(named: "run-script-bin"),
            arguments: arguments
        )
    }

    private func performCommand(
        packageDirectory: Path,
        tool: PluginContext.Tool,
        arguments: [String]
    ) throws {
        var argumentExtractor = ArgumentExtractor(arguments)
        let config = argumentExtractor.extractOption(named: "config").first
        ?? packageDirectory.firstConfigurationFileInParentDirectories()?.string ?? ""
        let timing = argumentExtractor.extractOption(named: "timing").first ?? "command"

        let process = Process()
        process.launchPath = tool.path.string
        process.arguments = [
            "--config",
            config,
            "--timing",
            timing
        ]

        try process.run()
        process.waitUntilExit()
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension RunScriptCommandPlugin: XcodeCommandPlugin {
    func performCommand(context: XcodeProjectPlugin.XcodePluginContext, arguments: [String]) throws {
        try performCommand(
            packageDirectory: context.xcodeProject.directory,
            tool: try context.tool(named: "run-script-bin"),
            arguments: arguments
        )
    }
}
#endif

// ref: https://github.com/realm/SwiftLint/blob/main/Plugins/SwiftLintPlugin/Path%2BHelpers.swift
extension Path {
    func firstConfigurationFileInParentDirectories() -> Path? {
        let defaultConfigurationFileNames = [
            "runscript.yml",
            ".runscript.yml"
        ]
        let proposedDirectories = sequence(
            first: self,
            next: { path in
                guard path.stem.count > 1 else {
                    // Check we're not at the root of this filesystem, as `removingLastComponent()`
                    // will continually return the root from itself.
                    return nil
                }

                return path.removingLastComponent()
            }
        )

        for proposedDirectory in proposedDirectories {
            for fileName in defaultConfigurationFileNames {
                let potentialConfigurationFile = proposedDirectory.appending(subpath: fileName)
                if potentialConfigurationFile.isAccessible() {
                    return potentialConfigurationFile
                }
            }
        }
        return nil
    }

    /// Safe way to check if the file is accessible from within the current process sandbox.
    private func isAccessible() -> Bool {
        let result = string.withCString { pointer in
            access(pointer, R_OK)
        }

        return result == 0
    }
}
