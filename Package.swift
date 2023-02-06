// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "RunScriptPlugin",
    products: [
        .plugin(
            name: "RunScriptPlugin",
            targets: ["RunScriptPlugin"]
        ),
        .executable(
            name: "run-script",
            targets: ["run-script"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.1")
    ],
    targets: [
        .executableTarget(
            name: "run-script",
            dependencies: [
                .product(name: "Yams", package: "Yams")
            ]
        ),
        .binaryTarget(
            name: "run-script-bin",
            url: "https://github.com/p-x9/RunScriptPlugin/releases/download/0.0.3/run-script-bin.artifactbundle.zip",
            checksum: "af1662fa2bf1b68196b89943c4d78f2cc565613da81e3d7b22b2738218c938bf"
        ),
//        DEBUG
//        .binaryTarget(name: "run-script-bin", path: "./run-script-bin.artifactbundle.zip"),
        .plugin(
            name: "RunScriptPlugin",
            capability: .buildTool(),
            dependencies: [
                "run-script-bin"
            ]
        )
    ]
)
