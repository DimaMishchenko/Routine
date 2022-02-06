import Foundation

final class ServiceFactory {
  func notificationsPermissionHandler() -> NotificationsPermissionHandler {
    NotificationsPermissionHandlerImpl()
  }
  
  func appStateObserver() -> AppStateObserver {
    AppStateObserverImpl()
  }
}
