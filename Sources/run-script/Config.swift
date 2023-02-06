//
//  Config.swift
//  
//
//  Created by p-x9 on 2023/02/04.
//  
//

import Foundation

struct Config: Codable {
    let prebuild: [Script]?
    let build: [Script]?
}

struct Script: Codable {
    let name: String?

    let launchPath: String?

    let path: String?
    let script: String?

    let arguments: [String]?
}
