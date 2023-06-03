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
      store: serviceFactory.routineStore(),
      itemFactory: RoutineListItemFactoryImpl(),
      appStateObserver: serviceFactory.appStateObserver(),
      notificationsHandler: serviceFactory.notificationsPermissionHandler(),
      inAppPurchases: serviceFactory.inAppPurchases()
    )
    let vc = RoutineListVC(presenter: presenter)
    presenter.view = vc
    
    presenter.premium = { [weak vc, weak assemblyFactory] in
      Task { [vc, assemblyFactory] in
        guard let premiumVC = await assemblyFactory?.premium().controller() else { return }
        await vc?.present(UINavigationController(rootViewController: premiumVC), animated: true)
      }
    }
    presenter.editRoutine = { [weak vc, weak assemblyFactory, weak presenter] routine, completion, onDelete in
      let editVC = assemblyFactory?.routineEdit().controller(
        for: .edit(routine),
        onSave: { completion($0) },
        onDelete: { onDelete() }
      )
      editVC.flatMap { vc?.present(UINavigationController(rootViewController: $0), animated: true) }
    }
    presenter.addNewRoutine = { [weak vc, weak assemblyFactory, weak presenter] completion in
      let editVC = assemblyFactory?.routineEdit().controller(
        for: .new,
        onSave: { completion($0) },
        onDelete: {}
      )
      editVC.flatMap { vc?.present(UINavigationController(rootViewController: $0), animated: true) }
    }
    presenter.routineDetails = { [weak vc, weak assemblyFactory] routine, onEdit in
      Task { [vc, assemblyFactory] in
        guard let detailsVC = await assemblyFactory?.routineDetails().controller(with: routine, onEdit: onEdit) else {
          return
        }
        await vc?.present(UINavigationController(rootViewController: detailsVC), animated: true)
      }
    }
    return vc
  }
}
