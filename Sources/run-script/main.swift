//
//  main.swift
//  
//
//  Created by p-x9 on 2023/02/04.
//  
//

import Foundation
import Yams

#if os(macOS)
enum CommandError: LocalizedError {
    case invalidArguments
}

func run() throws {
    let arguments = ProcessInfo().arguments

    guard arguments.count == 3 else {
        throw CommandError.invalidArguments
    }

    let configFilePath = arguments[1]
    let configFileURL = URL(fileURLWithPath: configFilePath)

    let isPrebuild: Bool = arguments[2] == "1"

    let fileManager = FileManager.default
    let decoder = YAMLDecoder()

    guard fileManager.fileExists(atPath: configFilePath) else {
        return
    }

    let data = try Data(contentsOf: configFileURL)
    let config = try decoder.decode(Config.self, from: data)

    let directory = configFileURL.deletingLastPathComponent().path
    FileManager.default.changeCurrentDirectoryPath(directory)

    let scripts = isPrebuild ? config.prebuild : config.build
    try scripts?.forEach {
        try run($0)
    }
}

func run(_ script: Script) throws {
    let process = Process()

    process.launchPath = script.launchPath ?? "/bin/sh"

    if let path = script.path {
        process.arguments = [path]
    } else if let script = script.script {
        process.arguments = ["-c", script]
    }

    process.launch()
    process.waitUntilExit()
}

do {
    try run()
    exit(0)
} catch {
    exit(1)
}
#endif
