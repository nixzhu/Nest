import ProjectDescription

let project = Project(
    name: "Nest",
    targets: [
        .target(
            name: "Nest",
            destinations: .iOS,
            product: .app,
            // swiftformat:disable acronyms
            bundleId: "dev.nixzhu.Nest",
            // swiftformat:enable acronyms
            deploymentTargets: .iOS("15.0"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleShortVersionString": "1.0",
                    "CFBundleVersion": "1",
                    "UILaunchScreen": [:],
                ]
            ),
            sources: ["Nest/Sources/**"],
            resources: ["Nest/Resources/**"],
            dependencies: []
        ),
    ]
)
