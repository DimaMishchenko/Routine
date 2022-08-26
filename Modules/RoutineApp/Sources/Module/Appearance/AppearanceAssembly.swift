import UIKit

final class AppearanceAssembly {
  // MARK: - Public
  @MainActor func controller() -> UIViewController {
    let vc = AppearanceVC(viewModel: AppearanceViewModelImpl())
    return vc
  }
}
