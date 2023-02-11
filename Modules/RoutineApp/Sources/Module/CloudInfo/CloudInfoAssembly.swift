import UIKit

final class CloudInfoAssembly {
  // MARK: - Public
  @MainActor func controller() -> UIViewController {
    let vc = CloudInfoVC(viewModel: CloudInfoViewModelImpl())
    return vc
  }
}
