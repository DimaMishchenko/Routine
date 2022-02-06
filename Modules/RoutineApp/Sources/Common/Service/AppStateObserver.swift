import Combine
import Foundation
import UIKit.UIApplication

enum AppStateEvent {
  case didEnterBackground
  case willEnterForeground
  case didBecomeActive
  case willResignActive
  case willTerminate
}

protocol AppStateObserver {
  func on(_ event: AppStateEvent) -> AnyPublisher<Void, Never>
}

final class AppStateObserverImpl: AppStateObserver {
  func on(_ event: AppStateEvent) -> AnyPublisher<Void, Never> {
    NotificationCenter.default
      .publisher(for: notificationName(for: event))
      .map { _ in Void() }
      .eraseToAnyPublisher()
  }
  
  // MARK: - Private
  private func notificationName(for event: AppStateEvent) -> NSNotification.Name {
    switch event {
    case .didEnterBackground:
      return UIApplication.didEnterBackgroundNotification
    case .willEnterForeground:
      return UIApplication.willEnterForegroundNotification
    case .didBecomeActive:
      return UIApplication.didBecomeActiveNotification
    case .willResignActive:
      return UIApplication.willResignActiveNotification
    case .willTerminate:
      return UIApplication.willTerminateNotification
    }
  }
}
