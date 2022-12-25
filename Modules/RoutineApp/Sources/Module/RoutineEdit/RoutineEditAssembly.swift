import EmojiPicker
import UIKit

final class RoutineEditAssembly {
  // MARK: - Dependencies
  private let serviceFactory: ServiceFactory
  
  // MARK: - Init
  init(serviceFactory: ServiceFactory) {
    self.serviceFactory = serviceFactory
  }
  
  // MARK: - Public
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
      EmojiPicker.present(on: vc, with: .init(sender: sourceView)) {
        completion($0)
      }
    }
    
    return vc
  }
}
