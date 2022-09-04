import Foundation

protocol RoutineHistoryUpdater {
  func handleAppLaunch()
}

final class RoutineHistoryUpdaterImpl: RoutineHistoryUpdater {
  // MARK: - Dependencies
  private let store: RoutineStore
  
  // MARK: - Init
  init(store: RoutineStore) {
    self.store = store
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleDayChange),
      name: .NSCalendarDayChanged,
      object: nil
    )
  }
  
  // MARK: - Public
  func handleAppLaunch() { fillHistory() }
  
  // MARK: - Private
  @objc private func handleDayChange() { fillHistory() }
  
  private func fillHistory() {
    Task(logError: true) {
      try await store.fillHistoryIfNeeded()
    }
  }
}
