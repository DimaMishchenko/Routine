import Foundation

@MainActor enum IntentRuntime {
  private static var runtime = AppRuntime.shared

  static func configure(runtime: AppRuntime? = nil) {
    self.runtime = runtime ?? .shared
  }

  static func store() throws -> RoutineStore {
    try runtime.serviceFactory().routineStore()
  }
}
