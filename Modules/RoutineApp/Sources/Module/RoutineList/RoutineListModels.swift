import Foundation

enum RoutineList {
  // MARK: - Section
  enum Section: Hashable {
    case daily
    case weekly
    case monthly
  }
  
  // MARK: - Header
  struct Header: Hashable {
    let model: GroupSupplementaryVM
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
    case empty(EmptyCellVM)
  }
}

// MARK: - Cell+Hashable
extension RoutineList.Row: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(type)
  }
  
  static func == (lhs: RoutineList.Row, rhs: RoutineList.Row) -> Bool {
    lhs.type == rhs.type
  }
}
