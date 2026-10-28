import Foundation

enum Logger {
  enum Level {
    case debug
    case info
    case warning
    case error

    var prefix: String {
      switch self {
      case .debug: return "⚙️"
      case .info: return "ℹ️"
      case .warning: return "⚠️"
      case .error: return "❗️"
      }
    }
  }

  static func log(
    _ level: Level,
    _ message: String,
    file: String = #file,
    function: String = #function,
    line: Int = #line
  ) {
    print("\(level.prefix) \(message)")
  }

  static func log(_ error: Error, file: String = #file, function: String = #function, line: Int = #line) {
    print("\(Level.error.prefix) \(String(describing: error))")
  }
}
