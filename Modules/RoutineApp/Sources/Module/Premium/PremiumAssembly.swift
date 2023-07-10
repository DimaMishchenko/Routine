import SafariServices
import UIKit

final class PremiumAssembly {
  // MARK: - Dependencies
  private let serviceFactory: ServiceFactory
  
  // MARK: - Init
  init(serviceFactory: ServiceFactory) {
    self.serviceFactory = serviceFactory
  }
  
  // MARK: - Public
  @MainActor func controller() -> UIViewController {
    let vm = PremiumViewModelImpl(purchases: serviceFactory.inAppPurchases())
    let vc = PremiumVC(viewModel: vm)
    vm.dismiss = { [weak vc] in
      vc?.dismiss(animated: true)
    }
    vm.openLinkInSafari = { [weak vc] in
      let safariVC = SFSafariViewController(
        url: $0,
        configuration: with(.init()) {
          $0.entersReaderIfAvailable = true
        }
      )
      vc?.present(safariVC, animated: true)
    }
    return vc
  }
}
