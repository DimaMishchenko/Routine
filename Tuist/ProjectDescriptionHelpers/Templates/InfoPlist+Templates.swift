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
        "LSApplicationQueriesSchemes": ["tg"]
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
    let path = (FileManager.default.currentDirectoryPath as NSString)
      .appendingPathComponent("Modules/RoutineApp/app-build")
    
    return try! String(contentsOfFile: path)
  }
}
