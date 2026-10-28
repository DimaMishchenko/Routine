import Foundation

final class ServiceFactory {
  private let sharedCoreDataStack: CoreDataStack
  init(coreDataStack: CoreDataStack) {
    sharedCoreDataStack = coreDataStack
  }
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
  
  func authenticator() -> Authenticator {
    AuthenticatorImpl()
  }
}
