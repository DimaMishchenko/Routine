import EmojiPicker
import UIKit

final class RoutineEditAssembly {
  private let assemblyFactory: AssemblyFactory
  private let serviceFactory: ServiceFactory
  init(assemblyFactory: AssemblyFactory, serviceFactory: ServiceFactory) {
    self.assemblyFactory = assemblyFactory
    self.serviceFactory = serviceFactory
  }
  func controller(
    for type: RoutineEdit.ModuleType,
    onSave: @escaping (Routine) -> Void,
    onDelete: @escaping () -> Void
  ) -> UIViewController {
    let presenter = RoutineEditPresenterImpl(
      moduleType: type,
      itemFactory: RoutineEditItemFactoryImpl(),
      notificationsHandler: serviceFactory.notificationsPermissionHandler()
    )
    let vc = RoutineEditVC(presenter: presenter)
    presenter.view = vc
    
    presenter.saveRoutine = { onSave($0) }
    presenter.deleteRoutine = { onDelete() }
    
    presenter.close = { [weak vc] in
      DispatchQueue.main.async {
        vc?.dismiss(animated: true)
      }
    }
    
    presenter.pickEmoji = { [weak vc] completion in
      guard let vc, let sourceView = vc.emojiSourceView else { return }
      
      vc.present(
        EmojiPickerAssembly().controller(with: sourceView) {
          completion($0)
        },
        animated: true
      )
    }
    
    return vc
  }
}
