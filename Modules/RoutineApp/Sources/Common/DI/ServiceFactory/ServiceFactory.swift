import Foundation

final class ServiceFactory {
  // MARK: - Dependencies
  private let sharedCoreDataStack: CoreDataStack
  
  // MARK: - Init
  init(coreDataStack: CoreDataStack) {
    sharedCoreDataStack = coreDataStack
  }
  
  // MARK: - Public
  func coreDataStack() -> CoreDataStack {
    sharedCoreDataStack
  }
  
  func notificationsPermissionHandler() -> NotificationsHandler {
    NotificationsHandlerImpl()
  }
  
  func appStateObserver() -> AppStateObserver {
    AppStateObserverImpl()
  }
  
  func routineStore() -> RoutineStore {
    CoreDataRoutineStore(coreDataStack: coreDataStack())
  }
  
  func routineHistoryUpdater() -> RoutineHistoryUpdater {
    RoutineHistoryUpdaterImpl(store: routineStore())
  }
}
