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
  
  func notificationsPermissionHandler() -> NotificationsPermissionHandler {
    NotificationsPermissionHandlerImpl()
  }
  
  func appStateObserver() -> AppStateObserver {
    AppStateObserverImpl()
  }
}
