import FirebaseCrashlytics
import Foundation

enum Logger {
  private static let destinations: [LoggerDestination] = [ConsoleDestination(), CrashlyticsDestination()]
  
  static func log(
    _ level: Level,
    _ message: String,
    file: String = #file,
    function: String = #function,
    line: Int = #line
  ) {
    destinations.forEach { $0.log(level, message, file: file, function: function, line: line) }
  }
  
  static func log(_ error: Error, file: String = #file, function: String = #function, line: Int = #line) {
    destinations.forEach { $0.log(error, file: file, function: function, line: line) }
  }
}

private protocol LoggerDestination {
  func log(_ level: Logger.Level, _ message: String, file: String, function: String, line: Int)
  func log(_ error: Error, file: String, function: String, line: Int)
}

extension Logger {
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
}

extension Logger {
  struct ConsoleDestination: LoggerDestination {
    func log(_ level: Logger.Level, _ message: String, file: String, function: String, line: Int) {
      print("\(level.prefix) \(message)")
    }
    
    func log(_ error: Error, file: String, function: String, line: Int) {
      print("\(Level.error.prefix) \(String(describing: error))")
    }
  }
  
  struct CrashlyticsDestination: LoggerDestination {
    private struct MessageError: Error, LocalizedError {
      let message: String
      var errorDescription: String { message }
    }
    
    func log(_ level: Logger.Level, _ message: String, file: String, function: String, line: Int) {
      switch level {
      case .debug, .info, .warning:
        Crashlytics.crashlytics().log(message)
      case .error:
        log(MessageError(message: message), file: file, function: function, line: line)
      }
    }
    
    func log(_ error: Error, file: String, function: String, line: Int) {
      let error = NSError(
        domain: (error as NSError).domain,
        code: (error as NSError).code,
        userInfo: (error as NSError).userInfo.merging(
          [
            "file": file,
            "function": function,
            "line": line,
            "dump": dump(error)
          ]
        ) { first, _ in
          first
        }
      )
      Crashlytics.crashlytics().record(error: error)
    }
  }
}
