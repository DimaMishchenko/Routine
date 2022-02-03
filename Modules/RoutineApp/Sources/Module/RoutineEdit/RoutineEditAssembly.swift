import EmojiPicker
import UIKit

final class RoutineEditAssembly {
  // MARK: - Public
  func controller(
    for type: RoutineEdit.ModuleType,
    onSave: @escaping (Routine) -> Void,
    onDelete: @escaping () -> Void
  ) -> UIViewController {
    let presenter = RoutineEditPresenterImpl(
      moduleType: type,
      itemFactory: RoutineEditItemFactoryImpl()
    )
    let vc = RoutineEditVC(presenter: presenter)
    presenter.view = vc
    
    presenter.saveRoutine = { onSave($0) }
    presenter.deleteRoutine = { onDelete() }
    
    presenter.close = { [weak vc] in
      vc?.dismiss(animated: true)
    }
    
    presenter.pickEmoji = { [weak vc] completion in
      let assembly = EmojiAssembly()
      let emojiVC = assembly.controller(sourceRect: vc?.emojiSourceRect ?? .zero) { emoji in
        completion(emoji)
      }
      vc?.present(emojiVC, animated: true)
    }
    
    presenter.pickFrequency = { [weak vc] frequency, completion in
      guard let view = vc?.view else { return }
      SheetPicker.frequency(selectedItem: frequency, from: view) {
        completion($0)
      }
    }
    
    presenter.pickGoal = { [weak vc] goal, completion in
      guard let view = vc?.view else { return }
      SheetPicker.goal(selectedItem: goal, from: view) {
        completion($0)
      }
    }
    
    presenter.pickTime = { [weak vc] date, completion in
      guard let view = vc?.view else { return }
      SheetPicker.time(title: .empty, selectedDate: date, from: view) {
        completion($0)
      }
    }
    
    return vc
  }
}
