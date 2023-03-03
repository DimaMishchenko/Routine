import UIKit

final class RoutineDetailsAssembly {
  // MARK: - Dependencies
  private let serviceFactory: ServiceFactory

  // MARK: - Init
  init(serviceFactory: ServiceFactory) {
    self.serviceFactory = serviceFactory
  }

  // MARK: - Public
  @MainActor func controller(with routine: Routine, onEdit: @escaping () -> Void) -> UIViewController {
    let viewModel = RoutineDetailsViewModelImpl(routine: routine, routineStore: serviceFactory.routineStore())
    let vc = RoutineDetailsVC(viewModel: viewModel)
    
    viewModel.dismiss = { [weak vc] in vc?.dismiss(animated: true) }
    viewModel.editRoutine = { onEdit() }
    viewModel.showAlert = { [weak vc] vm in
      vc.flatMap { Alert.show(on: $0, with: vm) }
    }
    
    return vc
  }
}
