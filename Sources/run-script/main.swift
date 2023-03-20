//
//  main.swift
//  
//
//  Created by p-x9 on 2023/02/04.
//  
//

import Foundation
import Yams
import ArgumentParser

#if os(macOS)
enum CommandError: LocalizedError {
    case configFileNotExsisted
}

enum Timing: String, EnumerableFlag, ExpressibleByArgument {
    case prebuild
    case build
    case command

    static func name(for value: Self) -> NameSpecification {
        .long
    }

    static func help(for value: Self) -> ArgumentHelp? {
        "run scripts defined with '\(value.rawValue)' in configuration file "
    }
}

struct RunScript: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "RunScript",
        abstract: "Run shell scripts configured in yaml files",
        version: "0.0.4",
        shouldDisplay: true,
        helpNames: [.long, .short]
    )

    @Option(help: "configuration file path (YAML)")
    var config: String

    @Option(help: "Which scripts to run in the configuration file")
    var timing: Timing

    func run() throws {
        let configFileURL = URL(fileURLWithPath: config)

        let fileManager = FileManager.default
        let decoder = YAMLDecoder()

        guard fileManager.fileExists(atPath: config) else {
            throw CommandError.configFileNotExsisted
        }

        let data = try Data(contentsOf: configFileURL)
        let config = try decoder.decode(Config.self, from: data)

        let directory = configFileURL.deletingLastPathComponent().path
        FileManager.default.changeCurrentDirectoryPath(directory)

        let scripts = config.scripts(for: timing)
        try scripts.forEach {
            try run($0)
        }
    }
}

extension RunScript {
    func run(_ script: Script) throws {
        let process = Process()

        process.launchPath = script.launchPath ?? "/bin/sh"

        if let path = script.path {
            process.arguments = [path]
        } else if let arguments = script.arguments, !arguments.isEmpty {
            process.arguments = arguments
        } else if let script = script.script {
            process.arguments = ["-c", script]
        }

        process.launch()
        process.waitUntilExit()
    }
}

RunScript.main()
#endif
