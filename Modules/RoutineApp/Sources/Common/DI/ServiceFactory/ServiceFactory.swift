import Foundation

final class ServiceFactory {
  // MARK: - Dependencies
  private let sharedCoreDataStack: CoreDataStack
  private let purchases: InAppPurchases
  
  // MARK: - Init
  init(coreDataStack: CoreDataStack, purchases: InAppPurchases) {
    sharedCoreDataStack = coreDataStack
    self.purchases = purchases
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
  
  func authenticator() -> Authenticator {
    AuthenticatorImpl()
  }
  
  func inAppPurchases() -> InAppPurchases {
    purchases
  }
}
