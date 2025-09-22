import ProjectDescription

let project = Project(
  name: "SkincareAI",
  packages: [
    // example: .package(url: "https://github.com/airbnb/lottie-ios.git", .upToNextMajor(from: "4.5.0"))
  ],
  targets: [
    .target(
      name: "App",
      destinations: .iOS,
      product: .app,
      bundleId: "com.yourorg.skincareai",
      infoPlist: .extendingDefault(with: [
        "UILaunchScreen": [:],
        "NSCameraUsageDescription": .string("We use the camera to analyze your skin on-device."),
        "NSPhotoLibraryAddUsageDescription": .string("Optional: Save progress photos to your library."),
      ]),
      sources: ["Projects/App/Sources/**"],
      resources: ["Projects/App/Resources/**"],
      dependencies: [
        .target(name: "CameraFeature"),
        .target(name: "MLCore"),
        .target(name: "Recommendations"),
        .target(name: "DesignSystem"),
        .target(name: "DataKit"),
      ]
    ),
    .target(
      name: "CameraFeature",
      destinations: .iOS,
      product: .framework,
      sources: ["Projects/CameraFeature/Sources/**"]
    ),
    .target(
      name: "MLCore",
      destinations: .iOS,
      product: .framework,
      sources: ["Projects/MLCore/Sources/**"]
    ),
    .target(
      name: "DataKit",
      destinations: .iOS,
      product: .framework,
      sources: ["Projects/DataKit/Sources/**"]
    ),
    .target(
      name: "Recommendations",
      destinations: .iOS,
      product: .framework,
      sources: ["Projects/Recommendations/Sources/**"],
      resources: ["Projects/Recommendations/Resources/**"],
      dependencies: [
        .target(name: "DataKit"),
        .target(name: "MLCore"),
      ]
    ),
    .target(
      name: "DesignSystem",
      destinations: .iOS,
      product: .framework,
      sources: ["Projects/DesignSystem/Sources/**"]
    ),
    .target(
      name: "AppTests",
      destinations: .iOS,
      product: .unitTests,
      sources: ["Projects/App/Tests/**"],
      dependencies: [.target(name: "App")]
    )
  ]
)
