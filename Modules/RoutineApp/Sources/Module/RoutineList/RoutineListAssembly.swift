import StoreKit
import UIKit

final class RoutineListAssembly {
  private let assemblyFactory: AssemblyFactory
  private let serviceFactory: ServiceFactory
  init(assemblyFactory: AssemblyFactory, serviceFactory: ServiceFactory) {
    self.assemblyFactory = assemblyFactory
    self.serviceFactory = serviceFactory
  }
  func controller() -> UIViewController {
    let presenter = RoutineListPresenterImpl(
      store: serviceFactory.routineStore(),
      itemFactory: RoutineListItemFactoryImpl(),
      appStateObserver: serviceFactory.appStateObserver(),
      notificationsHandler: serviceFactory.notificationsPermissionHandler()
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
    presenter.routineDetails = { [weak vc, weak assemblyFactory] routine, onEdit in
      Task { [vc, assemblyFactory] in
        guard let detailsVC = await assemblyFactory?.routineDetails().controller(with: routine, onEdit: onEdit) else {
          return
        }
        await vc?.present(UINavigationController(rootViewController: detailsVC), animated: true)
      }
    }
    presenter.inAppReview = {
      UIApplication.shared.activeWindowScene.flatMap {
        SKStoreReviewController.requestReview(in: $0)
      }
    }
    return vc
  }
}
