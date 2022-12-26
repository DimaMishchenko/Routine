import UIKit

final class TutorialAssembly {
  // MARK: - Public
  @MainActor func controller() -> UIViewController {
    let vm = TutorialViewModelImpl()
    let vc = TutorialVC(viewModel: vm)
    vm.onClose = { [weak vc] in
      vc?.dismiss(animated: true)
    }
    return vc
  }
}
