import StoreKit
import UIKit

final class SettingsAssembly {
  // MARK: - Dependencies
  private let assemblyFactory: AssemblyFactory
  
  // MARK: - Init
  init(assemblyFactory: AssemblyFactory) {
    self.assemblyFactory = assemblyFactory
  }
  
  // MARK: - Public
  func controller() -> UIViewController {
    let presenter = SettingsPresenterImpl(rowFactory: SettingsRowFactoryImpl())
    let vc = SettingsVC(presenter: presenter)
    presenter.view = vc
    
    presenter.openSettings = { ExternalLinksNavigator.systemSettings() }
    presenter.rateApp = { SKStoreReviewController.requestReview() }
    
    presenter.reportBug = { [weak assemblyFactory, weak vc] in
      // TODO: - Add options (telegram)
      let controllerProxy = assemblyFactory?.mail().controller(
        subject: RoutineStrings.Settings.Mail.ReportBug.subject,
        message: RoutineStrings.Settings.Mail.ReportBug.message,
        addDebugData: true,
        onResult: { _, _ in
          // TODO: - Analytics event
        }
      )
      controllerProxy.flatMap { vc?.present($0.controller, animated: true) }
    }
    
    presenter.suggestFeature = { [weak assemblyFactory, weak vc] in
      // TODO: - Add options (telegram)
      let controllerProxy = assemblyFactory?.mail().controller(
        subject: RoutineStrings.Settings.Mail.SuggestFeature.subject,
        message: RoutineStrings.Settings.Mail.SuggestFeature.message,
        addDebugData: true,
        onResult: { _, _ in
          // TODO: - Analytics event
        }
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
