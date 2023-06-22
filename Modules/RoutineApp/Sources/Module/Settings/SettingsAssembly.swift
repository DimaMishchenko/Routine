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
      notificationsHandler: serviceFactory.notificationsPermissionHandler(),
      identifierCopyHandler: UserIdentifierCopyHandler(),
      authenticator: serviceFactory.authenticator(),
      inAppPurchases: serviceFactory.inAppPurchases()
    )
    let vc = SettingsVC(presenter: presenter)
    presenter.view = vc
    
    presenter.premium = { [weak vc, weak assemblyFactory] in
      Task { [vc, assemblyFactory] in
        guard let premiumVC = await assemblyFactory?.premium().controller() else { return }
        await vc?.present(UINavigationController(rootViewController: premiumVC), animated: true)
      }
    }
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
      // TODO: - replace withr remote config
      guard
        let url = URL(string: "https://apps.apple.com/us/app/routine-daily-tracker/id1643340709"),
        let shareVC = assemblyFactory?.share().controller(items: [url])
      else {
        return
      }
      vc?.present(shareVC, animated: true)
    }
    
    presenter.openCloudInfo = { [weak assemblyFactory, weak vc] in
      Task { [assemblyFactory, vc] in
        guard let appearanceVC = await assemblyFactory?.cloudInfo().controller() else { return }
        
        if let nc = await vc?.navigationController {
          await nc.pushViewController(appearanceVC, animated: true)
        } else {
          await vc?.present(UINavigationController(rootViewController: appearanceVC), animated: true)
        }
      }
    }
    
    presenter.openAppearance = { [weak assemblyFactory, weak vc] in
      Task { [assemblyFactory, vc] in
        guard let appearanceVC = await assemblyFactory?.appearance().controller() else { return }
        
        if let nc = await vc?.navigationController {
          await nc.pushViewController(appearanceVC, animated: true)
        } else {
          await vc?.present(UINavigationController(rootViewController: appearanceVC), animated: true)
        }
      }
    }

    presenter.openTutorial = { [weak assemblyFactory, weak vc] in
      Task { [assemblyFactory, vc] in
        guard let tutorialVC = await assemblyFactory?.tutorial().controller() else { return }
        await vc?.present(tutorialVC, animated: true)
      }
    }
    
    presenter.openMacApp = { ExternalLinksNavigator.macApp() }
    
    return vc
  }
}
