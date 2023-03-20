//
//  Config.swift
//  
//
//  Created by p-x9 on 2023/02/04.
//  
//

import Foundation

#if os(macOS)
struct Config: Codable {
    let prebuild: [Script]?
    let build: [Script]?
    let command: [Script]?
    let all: [Script]?
}

struct Script: Codable {
    let name: String?

    let launchPath: String?

    let path: String?
    let script: String?

    let arguments: [String]?
}

extension Config {
    func scripts(for timing: Timing) -> [Script] {
        let all = all ?? []
        switch timing {
        case .prebuild:
            return (prebuild ?? []) + all
        case .build:
            return (build ?? []) + all
        case .command:
            return (command ?? []) + all
        }
    }
}
#endif
