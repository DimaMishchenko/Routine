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
}

final class RoutineEditPresenterImpl: RoutineEditPresenter {
  // MARK: - Dependencies
  weak var view: RoutineEditViewInterface?
  private let itemFactory: RoutineEditItemFactory
  
  // MARK: - Action Properties
  var saveRoutine: ((Routine) -> Void)?
  var deleteRoutine: (() -> Void)?
  var close: (() -> Void)?
  var pickEmoji: ((@escaping (String) -> Void) -> Void)?
  var pickFrequency: ((Frequency, @escaping (Frequency) -> Void) -> Void)?
  var pickGoal: ((Progress.Goal, @escaping (Progress.Goal) -> Void) -> Void)?
  var pickTime: ((Date, @escaping (Date) -> Void) -> Void)?
  
  // MARK: - Private Properties
  private let moduleType: RoutineEdit.ModuleType
  private var editableRoutine: EditableRoutine
  
  // MARK: - Init
  init(
    moduleType: RoutineEdit.ModuleType,
    itemFactory: RoutineEditItemFactory
  ) {
    self.moduleType = moduleType
    self.itemFactory = itemFactory
    
    switch moduleType {
    case .new: editableRoutine = EditableRoutine(routine: .new)
    case .edit(let routine): editableRoutine = EditableRoutine(routine: routine)
    }
  }
  
  // MARK: - RoutineEditPresenter
  func viewDidLoad() {
    switch moduleType {
    case .new:
      view?.update(title: RoutineAppStrings.RoutineEdit.Title.create)
      view?.updateDelete(visibility: false)
    case .edit:
      view?.update(title: RoutineAppStrings.RoutineEdit.Title.edit)
      view?.updateDelete(visibility: true)
    }
    
    reloadSnapshot()
  }
  
  func cancelEdit() {
    close?()
  }
  
  func save() {
    saveRoutine?(editableRoutine.routine)
    close?()
  }
  
  func delete() {
    // TODO: - Add warning alert
    deleteRoutine?()
    close?()
  }
  
  func nameChanged(_ name: String) {
    editableRoutine.name = name
  }
  
  func descriptionChanged(_ description: String) {
    editableRoutine.description = description
  }
  
  func remindMeChangeRequest(_ currentState: Bool) {
    editableRoutine.remind = !currentState
    reloadSnapshot()
  }
  
  func addReminder() {
    editableRoutine.reminders.append(Reminder(uuid: UUID(), type: .daily(.from(date: Date()))))
    reloadSnapshot()
  }
  
  func deleteReminder(at index: Int) {
    editableRoutine.reminders.remove(at: index)
    reloadSnapshot()
  }
}

// MARK: - Private
extension RoutineEditPresenterImpl {
  private func reloadSnapshot() {
    typealias Item = Snapshot<RoutineEdit.Section, RoutineEdit.Row>.Item
    
    view?.update(
      with: Snapshot {
        Item(section: .name, rows: [
          .init(
            .textfield(
              .init(
                text: editableRoutine.name,
                placeholder: RoutineAppStrings.RoutineEdit.Placeholder.name
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
        
        itemFactory.frequency(with: editableRoutine.frequency) { [weak self] in
          guard let self = self else { return }
          self.pickFrequency?(self.editableRoutine.frequency) {
            self.editableRoutine.frequency = $0
            self.reloadSnapshot()
          }
        }
        
        itemFactory.goal(with: editableRoutine.progress.goal) { [weak self] in
          guard let self = self else { return }
          self.pickGoal?(self.editableRoutine.progress.goal) {
            self.editableRoutine.progress = Progress(goal: $0, current: self.editableRoutine.progress.current)
            self.reloadSnapshot()
          }
        }
        
        Item(section: .remindMe, rows: [
          .init(.switch(.init(title: RoutineAppStrings.RoutineEdit.Text.remindeMe, state: editableRoutine.remind)))
        ])
        
        if editableRoutine.remind {
          if !editableRoutine.reminders.isEmpty {
            Item(section: .reminders, rows: remindersRows())
          }
          
          Item(section: .addReminder, rows: [
            .init(.plainButton(.init(title: RoutineAppStrings.RoutineEdit.Text.addReminder)))
          ])
        }
        
        Item(section: .description, rows: [
          .init(
            .textview(
              .init(
                text: editableRoutine.description,
                placeholder: RoutineAppStrings.RoutineEdit.Placeholder.description
              )
            )
          )
        ])
      }
    )
  }
  
  private func remindersRows() -> [RoutineEdit.Row] {
    editableRoutine.reminders.enumerated().map { index, reminder in
      let value: String = {
        switch reminder.type {
        case .daily(let daily):
          return daily.date?.time ?? .empty
        }
      }()
      
      let title = RoutineAppStrings.RoutineEdit.Text.time
      
      return .init(.reminder(.init(uuid: reminder.uuid.uuidString, title: title, value: value))) { [weak self] in
        switch reminder.type {
        case .daily(let daily):
          self?.pickTime?(daily.date ?? Date()) {
            self?.editableRoutine.reminders[index] = .init(
              uuid: reminder.uuid,
              type: .daily(.from(date: $0))
            )
            self?.reloadSnapshot()
          }
        }
      }
    }
  }
}
