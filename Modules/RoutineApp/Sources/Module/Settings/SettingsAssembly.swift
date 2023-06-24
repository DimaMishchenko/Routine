import SafariServices
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
  // swiftlint:disable:next function_body_length
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
    presenter.telegramSupport = {
      Analytics.send(.supportTG)
      ExternalLinksNavigator.telegramSupport()
    }
    presenter.rateApp = {
      Analytics.send(.rateApp)
      ExternalLinksNavigator.appStore()
      // TODO: - find better approach
//      UIApplication.shared.activeWindowScene.flatMap {
//        SKStoreReviewController.requestReview(in: $0)
//      }
    }

    presenter.mailSupport = { [weak assemblyFactory, weak vc] subject, message in
      let mailVC = assemblyFactory?.mail().controller(
        subject: subject,
        message: message,
        addDebugData: true,
        onResult: { _, _ in Analytics.send(.supportMail) }
      )
      mailVC.flatMap { vc?.present($0, animated: true) }
    }

    presenter.share = { [weak assemblyFactory, weak vc] in
      guard
        let url = Flag.appStoreLink,
        let shareVC = assemblyFactory?.share().controller(items: [url])
      else {
        return
      }
      Analytics.send(.share)
      if UIDevice.current.userInterfaceIdiom != .phone {
        shareVC.popoverPresentationController?.sourceView = vc?.view
        shareVC.popoverPresentationController?.sourceRect = CGRect(
          x: vc?.view.frame.width ?? .zero,
          y: vc?.view.frame.height ?? .zero,
          width: .zero,
          height: .zero
        )
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

    presenter.openMacApp = {
      Analytics.send(.macLink)
      ExternalLinksNavigator.macApp()
    }

    presenter.privacyPolicy = { [weak vc] in
      Task { [vc] in
        guard let url = Flag.privacyPolicyLink else { return }
        let safariVC = await SFSafariViewController(
          url: url,
          configuration: with(.init()) {
            $0.entersReaderIfAvailable = true
          }
        )
        Analytics.send(.privacyPolicy)
        await vc?.present(safariVC, animated: true)
      }
    }

    return vc
  }
}
