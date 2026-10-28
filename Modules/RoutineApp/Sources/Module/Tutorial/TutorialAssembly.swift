import UIKit

final class TutorialAssembly {
  @MainActor func controller(onComplete: (() -> Void)? = nil) -> UIViewController {
    let vm = TutorialViewModelImpl()
    let vc = TutorialVC(viewModel: vm)
    vm.onClose = { [weak vc] in
      vc?.dismiss(animated: true, completion: onComplete)
    }
    return vc
  }
}
