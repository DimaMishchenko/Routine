import Combine
import Foundation

protocol RoutineHistoryUpdater {
  func handleAppLaunch()
  func handleForeground()
}

final class RoutineHistoryUpdaterImpl: RoutineHistoryUpdater {
  private enum Event {
    case snapshot([Routine])
    case retry
  }

  private let store: RoutineStore
  private let retry = PassthroughSubject<Void, Never>()
  private var observations = Set<AnyCancellable>()
  private var snapshots: AsyncStream<Event>.Continuation?
  private var reconciliationTask: Task<Void, Never>?

  init(store: RoutineStore, notifications: NotificationsHandler = NotificationsHandlerImpl()) {
    self.store = store
    let stream = AsyncStream<Event> { snapshots = $0 }
    let continuation = snapshots
    reconciliationTask = Task {
      var latestRoutines: [Routine]?
      for await event in stream {
        if case .snapshot(let routines) = event { latestRoutines = routines }
        guard let routines = latestRoutines else { continue }
        do {
          try await notifications.reconcile(routines)
        } catch {
          Logger.log(error)
        }
      }
    }
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleDayChange),
      name: .NSCalendarDayChanged,
      object: nil
    )
    store.observeAll()
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { completion in
        if case .failure(let error) = completion { Logger.log(error) }
      }, receiveValue: { routines in
        continuation?.yield(.snapshot(routines))
      })
      .store(in: &observations)
    retry.receive(on: DispatchQueue.main)
      .sink { continuation?.yield(.retry) }
      .store(in: &observations)
  }

  deinit {
    snapshots?.finish()
    reconciliationTask?.cancel()
  }

  func handleAppLaunch() { fillHistory() }
  func handleForeground() { fillHistory() }

  @objc private func handleDayChange() { fillHistory() }

  private func fillHistory() {
    Task(logError: true) { [store, retry] in
      try await store.fillHistoryIfNeeded()
      retry.send(())
    }
  }
}
