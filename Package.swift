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
            url: "https://github.com/p-x9/RunScriptPlugin/releases/download/0.0.1/run-script-bin.artifactbundle.zip",
            checksum: "660213786af538f6ec94dd4bc1fa29fcf42b7a157fb786d8d152466fc35e724f"
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
