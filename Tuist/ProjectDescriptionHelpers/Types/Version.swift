import Foundation
import ProjectDescription

enum Version {
  static var appVersion: String {
    let path = (FileManager.default.currentDirectoryPath as NSString)
      .appendingPathComponent("Modules/RoutineApp/app-version")
    
    return try! String(contentsOfFile: path).trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  static var buildNumber: String {
    ProjectDescription.Environment.buildNumber.getString(default: "1")
  }
}
