import StoreKit
import UIKit

final class SettingsAssembly {
  // MARK: - Dependencies
  private let assemblyFactory: AssemblyFactory
  private let serviceFactory: ServiceFactory
  
  // MARK: - Init
  init(assemblyFactory: AssemblyFactory, serviceFactory: ServiceFactory) {
    self.assemblyFactory = assemblyFactory
    self.serviceFactory = serviceFactory
  }
  
  // MARK: - Public
  func controller() -> UIViewController {
    let presenter = SettingsPresenterImpl(
      rowFactory: SettingsRowFactoryImpl(),
      appStateObserver: serviceFactory.appStateObserver(),
      notificationsHandler: serviceFactory.notificationsPermissionHandler()
    )
    let vc = SettingsVC(presenter: presenter)
    presenter.view = vc
    
    presenter.openSettings = { ExternalLinksNavigator.systemSettings() }
    presenter.telegramSupport = { ExternalLinksNavigator.telegramSupport() }
    presenter.rateApp = {
      UIApplication.shared.activeWindowScene.flatMap {
        SKStoreReviewController.requestReview(in: $0)        
      }
    }
    
    presenter.mailSupport = { [weak assemblyFactory, weak vc] subject, message in
      let controllerProxy = assemblyFactory?.mail().controller(
        subject: subject,
        message: message,
        addDebugData: true,
        onResult: { _, _ in /* TODO: - Analytics event */ }
      )
      controllerProxy.flatMap { vc?.present($0.controller, animated: true) }
    }
    
    presenter.share = { [weak assemblyFactory, weak vc] in
      // TODO: - Set AppStore URL
      guard
        let url = URL(string: "https://google.com"),
        let shareVC = assemblyFactory?.share().controller(items: [url])
      else {
        return
      }
      vc?.present(shareVC, animated: true)
    }
    
    return vc
  }
}
