import Foundation

enum RoutineEdit {
  // MARK: - Module Type
  enum ModuleType {
    case new
    case edit(Routine)
  }
  
  // MARK: - Errors
  enum ValidationError: Error {
    case emptyName
  }
  
  // MARK: - Section
  enum Section: Hashable {
    case name
    case emoji
    case frequency
    case goal
    case remindMe
    case reminders
    case addReminder
    case description
  }

  // MARK: - Row
  struct Row {
    let type: RowType
    let action: (() -> Void)?
    
    init(
      _ type: RowType,
      action: (() -> Void)? = nil
    ) {
      self.type = type
      self.action = action
    }
  }
  
  enum RowType: Hashable {
    case textfield(TextFieldCellVM)
    case textview(TextViewCellVM)
    case value(ValueCellVM)
    case `switch`(SwitchCellVM)
    case plainButton(PlainButtonCellVM)
    case reminder(ReminderCellVM)
  }
}

// MARK: - Cell+Hashable
extension RoutineEdit.Row: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(type)
  }
  
  static func == (lhs: RoutineEdit.Row, rhs: RoutineEdit.Row) -> Bool {
    lhs.type == rhs.type
  }
}
