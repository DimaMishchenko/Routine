import UIKit

final class RoutineListAssembly {
  // MARK: - Dependencies
  private let assemblyFactory: AssemblyFactory
  
  // MARK: - Init
  init(assemblyFactory: AssemblyFactory) {
    self.assemblyFactory = assemblyFactory
  }
  
  // MARK: - Public
  func controller() -> UIViewController {
    let presenter = RoutineListPresenterImpl()
    let vc = RoutineListVC(presenter: presenter)
    presenter.view = vc
    
    presenter.addNewRoutine = { [weak vc, weak assemblyFactory] in
      let editVC = assemblyFactory?.routineEdit().controller(
        for: .new,
        onSave: { _ in },
        onDelete: {}
      )
      editVC.flatMap { vc?.present(UINavigationController(rootViewController: $0), animated: true) }
    }
    return vc
  }
}
