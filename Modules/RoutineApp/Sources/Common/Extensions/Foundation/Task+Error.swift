import Foundation

extension Task where Failure == Error {
  @discardableResult
  init(
    priority: TaskPriority? = nil,
    logError: Bool,
    file: String = #file,
    function: String = #function,
    line: Int = #line,
    @_inheritActorContext @_implicitSelfCapture operation: __owned @escaping @Sendable () async throws -> Success
  ) {
    self.init(priority: priority) {
      do {
        return try await operation()
      } catch {
        Logger.log(error, file: file, function: function, line: line)
        throw error
      }
    }
  }
}
