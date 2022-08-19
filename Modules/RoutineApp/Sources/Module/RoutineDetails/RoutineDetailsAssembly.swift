import UIKit

final class RoutineDetailsAssembly {
  // MARK: - Public
  @MainActor func controller(with routine: Routine, onEdit: @escaping () -> Void) -> UIViewController {
    let viewModel = RoutineDetailsViewModelImpl(routine: routine)
    let vc = RoutineDetailsVC(viewModel: viewModel)
    
    viewModel.dismiss = { [weak vc] in vc?.dismiss(animated: true) }
    viewModel.editRoutine = { onEdit() }
    
    return vc
  }
}
