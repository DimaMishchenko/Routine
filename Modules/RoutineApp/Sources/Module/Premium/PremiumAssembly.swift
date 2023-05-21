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
    return vc
  }
}
