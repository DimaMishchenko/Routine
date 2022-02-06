import UserNotifications

protocol NotificationsPermissionHandler {
  func isAuthorized() async -> Bool
  func request() async -> Bool
}

final class NotificationsPermissionHandlerImpl: NotificationsPermissionHandler {
  func isAuthorized() async -> Bool {
    let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    return status == .authorized
  }
  
  func request() async -> Bool {
    do {
      let result = try await UNUserNotificationCenter.current().requestAuthorization(
        options: [.badge, .sound, .alert]
      )
      return result
    } catch {
      print(error) // TODO: - replace with os_log and Crashlytics non-fatal
      return false
    }
  }
}
