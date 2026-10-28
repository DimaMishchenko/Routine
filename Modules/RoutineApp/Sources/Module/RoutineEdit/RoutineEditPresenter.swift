import Foundation

protocol RoutineEditPresenter {
  func viewDidLoad()
  func cancelEdit()
  func save()
  func delete()
  func nameChanged(_ name: String)
  func descriptionChanged(_ description: String)
  func remindMeChangeRequest(_ currentState: Bool)
  func addReminder()
  func deleteReminder(at index: Int)
  func updateReminder(date: Date, at index: Int)
  func goalChanged(_ goal: Progress.Goal)
  func frequencyChanged(_ frequency: Frequency)
}

final class RoutineEditPresenterImpl: RoutineEditPresenter {
  weak var view: RoutineEditViewInterface?
  private let itemFactory: RoutineEditItemFactory
  private let notificationsHandler: NotificationsHandler
  var saveRoutine: ((Routine) -> Void)?
  var deleteRoutine: (() -> Void)?
  var close: (() -> Void)?
  var pickEmoji: ((@escaping (String) -> Void) -> Void)?
  private let moduleType: RoutineEdit.ModuleType
  private var editableRoutine: EditableRoutine
  init(
    moduleType: RoutineEdit.ModuleType,
    itemFactory: RoutineEditItemFactory,
    notificationsHandler: NotificationsHandler
  ) {
    self.moduleType = moduleType
    self.itemFactory = itemFactory
    self.notificationsHandler = notificationsHandler
    
    switch moduleType {
    case .new: editableRoutine = EditableRoutine(routine: .new)
    case .edit(let routine): editableRoutine = EditableRoutine(routine: routine)
    }
  }
  func viewDidLoad() {
    switch moduleType {
    case .new:
      view?.update(title: RoutineAppStrings.Localizable.RoutineEdit.Title.create)
      view?.updateDelete(visibility: false)
    case .edit:
      view?.update(title: RoutineAppStrings.Localizable.RoutineEdit.Title.edit)
      view?.updateDelete(visibility: true)
    }
    
    reloadSnapshot()
  }
  
  func cancelEdit() {
    close?()
  }
  
  func save() {
    let routine = editableRoutine.routine
    
    switch validate(routine) {
    case .success:
      saveRoutine?(routine)
      close?()
    case .failure(let error):
      view?.showAlert(with: validationErrorAlertVM(error))
    }
  }
  
  func delete() {
    view?.showAlert(
      with: .deleteAlert { [weak self] in
        self?.deleteRoutine?()
        self?.close?()
      }
    )
  }
  
  func nameChanged(_ name: String) {
    editableRoutine.name = name
  }
  
  func descriptionChanged(_ description: String) {
    editableRoutine.description = description
  }
  
  func remindMeChangeRequest(_ currentState: Bool) {
    if currentState {
      updateRemindMeState(false)
      return
    }
    Task(priority: .userInitiated) {
      if await notificationsHandler.isAuthorized() {
        updateRemindMeState(!currentState)
      } else if await notificationsHandler.request() {
        updateRemindMeState(!currentState)
      } else {
        view?.showAlert(with: notificationsDisabledAlertVM())
      }
    }
  }
  
  func addReminder() {
    editableRoutine.reminders.append(Reminder(uuid: UUID(), type: .daily(.from(date: Date()))))
    reloadSnapshot()
  }
  
  func deleteReminder(at index: Int) {
    editableRoutine.reminders.remove(at: index)
    reloadSnapshot()
  }
  
  func updateReminder(date: Date, at index: Int) {
    guard let reminder = editableRoutine.reminders[safe: index] else { return }
    switch reminder.type {
    case .daily:
      editableRoutine.reminders[index] = .init(
        uuid: reminder.uuid,
        type: .daily(.from(date: date))
      )
    }
  }
  
  func goalChanged(_ goal: Progress.Goal) {
    editableRoutine.progress = Progress(goal: goal, current: editableRoutine.progress.current)
    reloadSnapshot()
  }
  
  func frequencyChanged(_ frequency: Frequency) {
    editableRoutine.frequency = frequency
    reloadSnapshot()
  }
}
extension RoutineEditPresenterImpl {
  private func updateRemindMeState(_ newState: Bool) {
    editableRoutine.remind = newState
    reloadSnapshot()
  }
  
  private func validate(_ routine: Routine) -> Result<Void, RoutineEdit.ValidationError> {
    if routine.name.isEmpty {
      return .failure(.emptyName)
    }
    
    return .success(())
  }
  
  private func reloadSnapshot() {
    typealias Item = Snapshot<RoutineEdit.Section, RoutineEdit.Row>.Item
    
    view?.update(
      with: Snapshot {
        Item(section: .name, rows: [
          .init(
            .textfield(
              .init(
                text: editableRoutine.name,
                placeholder: RoutineAppStrings.Localizable.RoutineEdit.Placeholder.name
              )
            )
          )
        ])
        
        itemFactory.emoji(with: editableRoutine.emoji) { [weak self] in
          self?.pickEmoji? { emoji in
            self?.editableRoutine.emoji = emoji
            self?.reloadSnapshot()
          }
        }
        
        if case .new = moduleType {
          itemFactory.frequency(with: editableRoutine.frequency)
        }
        
        itemFactory.goal(with: editableRoutine.progress.goal)
        
        Item(section: .remindMe, rows: [
          .init(
            .switch(
              .init(title: RoutineAppStrings.Localizable.RoutineEdit.Text.remindeMe, state: editableRoutine.remind)
            )
          )
        ])
        
        if editableRoutine.remind {
          if !editableRoutine.reminders.isEmpty {
            Item(section: .reminders, rows: remindersRows())
          }
          
          Item(section: .addReminder, rows: [
            .init(.plainButton(.init(title: RoutineAppStrings.Localizable.RoutineEdit.Text.addReminder)))
          ])
        }
        
        Item(section: .description, rows: [
          .init(
            .textview(
              .init(
                text: editableRoutine.description,
                placeholder: RoutineAppStrings.Localizable.RoutineEdit.Placeholder.description
              )
            )
          )
        ])
      }
    )
  }
  
  private func remindersRows() -> [RoutineEdit.Row] {
    editableRoutine.reminders.map { reminder in
      let date: Date = {
        switch reminder.type {
        case .daily(let daily):
          return daily.date ?? Date()
        }
      }()
      
      let title = RoutineAppStrings.Localizable.RoutineEdit.Text.time
      
      return .init(.reminder(.init(uuid: reminder.uuid.uuidString, title: title, date: date)))
    }
  }
  
  private func validationErrorAlertVM(_ error: RoutineEdit.ValidationError) -> Alert.VM {
    switch error {
    case .emptyName:
      return .init(
        title: RoutineAppStrings.Localizable.RoutineEdit.Alert.Error.title,
        message: RoutineAppStrings.Localizable.RoutineEdit.Alert.Error.EmptyName.message,
        actions: [.ok],
        handler: { _ in }
      )
    }
  }
  
  private func notificationsDisabledAlertVM() -> Alert.VM {
    .init(
      title: RoutineAppStrings.Localizable.RoutineEdit.Alert.NotificationsDiabled.title,
      message: RoutineAppStrings.Localizable.RoutineEdit.Alert.NotificationsDiabled.message,
      actions: [.ok],
      handler: { _ in }
    )
  }
}
