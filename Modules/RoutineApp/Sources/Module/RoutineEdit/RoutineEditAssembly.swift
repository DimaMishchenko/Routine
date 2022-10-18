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
      let assembly = EmojiAssembly()
      let emojiVC = assembly.controller(sourceRect: vc?.emojiSourceRect ?? .zero) { emoji in
        completion(emoji)
      }
      vc?.present(emojiVC, animated: true)
    }
    
    return vc
  }
}
