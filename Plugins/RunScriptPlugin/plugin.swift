//
//  plugin.swift
//  
//
//  Created by p-x9 on 2023/02/04.
//  
//

import Foundation
import PackagePlugin

@main
struct RunScriptPlugin: BuildToolPlugin {
    func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        createBuildCommands(
            packageDirectory: context.package.directory,
            workingDirectory: context.pluginWorkDirectory,
            tool: try context.tool(named: "run-script-bin")
        )
    }

    private func createBuildCommands(
        packageDirectory: Path,
        workingDirectory: Path,
        tool: PluginContext.Tool
    ) -> [Command] {
        guard let configuration = packageDirectory.firstConfigurationFileInParentDirectories() else {
            return []
        }

        let arguments = ["--config", configuration.string]

        return [
            .prebuildCommand(
                displayName: "RunScriptPlugin(PreBuild)",
                executable: tool.path,
                arguments: arguments + ["--timing", "prebuild"],
                outputFilesDirectory: workingDirectory
            ),
            .buildCommand(
                displayName: "RunScriptPlugin(Build)",
                executable: tool.path,
                arguments: arguments + ["--timing", "build"]
            )
        ]
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension RunScriptPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        return createBuildCommands(
            packageDirectory: context.xcodeProject.directory,
            workingDirectory: context.pluginWorkDirectory,
            tool: try context.tool(named: "run-script-bin")
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

