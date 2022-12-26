import Foundation
import ProjectDescription

extension InfoPlist {
  static var routineApp: InfoPlist {
    .extendingDefault(
      with: [
        "CFBundleShortVersionString": .string(appVersion()),
        "CFBundleVersion": .string(appBuild()),
        "UIMainStoryboardFile": "",
        "UILaunchStoryboardName": "LaunchScreen",
        "ENVIRONMENT": "${ENVIRONMENT}",
        "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"],
        "LSApplicationQueriesSchemes": ["tg"],
        "LSApplicationCategoryType": "public.app-category.productivity",
        "ITSAppUsesNonExemptEncryption": false,
        "UIApplicationSceneManifest": [
          "UIApplicationSupportsMultipleScenes": false,
          "UISceneConfigurations": [
            "UIWindowSceneSessionRoleApplication": [
              [
                "UISceneConfigurationName": "Default Configuration",
                "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
              ]            
            ]
          ]
        ],
        "UIBackgroundModes": [
          "remote-notification"
        ]
      ]
    )
  }
  
  // MARK: - Private
  private static func appVersion() -> String {
    let path = (FileManager.default.currentDirectoryPath as NSString)
      .appendingPathComponent("Modules/RoutineApp/app-version")
    
    return try! String(contentsOfFile: path)
  }
  
  private static func appBuild() -> String {
    return ProjectDescription.Environment.buildNumber.getString(default: "1")
  }
}
