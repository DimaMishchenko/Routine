import UIKit

final class RoutineListAssembly {
  // MARK: - Dependencies
  private let assemblyFactory: AssemblyFactory
  private let serviceFactory: ServiceFactory
  
  // MARK: - Init
  init(assemblyFactory: AssemblyFactory, serviceFactory: ServiceFactory) {
    self.assemblyFactory = assemblyFactory
    self.serviceFactory = serviceFactory
  }
  
  // MARK: - Public
  func controller() -> UIViewController {
    let presenter = RoutineListPresenterImpl(
      provider: CoreDataRoutineProvider(coreDataStack: serviceFactory.coreDataStack()),
      itemFactory: RoutineListItemFactoryImpl()
    )
    let vc = RoutineListVC(presenter: presenter)
    presenter.view = vc
    
    presenter.editRoutine = { [weak vc, weak assemblyFactory] routine, completion, onDelete in
      let editVC = assemblyFactory?.routineEdit().controller(
        for: .edit(routine),
        onSave: { completion($0) },
        onDelete: { onDelete() }
      )
      editVC.flatMap { vc?.present(UINavigationController(rootViewController: $0), animated: true) }
    }
    presenter.addNewRoutine = { [weak vc, weak assemblyFactory] completion in
      let editVC = assemblyFactory?.routineEdit().controller(
        for: .new,
        onSave: { completion($0) },
        onDelete: {}
      )
      editVC.flatMap { vc?.present(UINavigationController(rootViewController: $0), animated: true) }
    }
    return vc
  }
}
