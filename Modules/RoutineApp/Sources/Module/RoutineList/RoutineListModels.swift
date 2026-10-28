import Foundation

enum RoutineList {
  enum Section: Int, Hashable {
    case daily
    case weekly
    case monthly
  }
  struct Header: Hashable {
    let model: GroupSupplementaryVM
  }
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
    case routine(RoutineCellVM)
  }
}
extension RoutineList.Row: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(type)
  }
  
  static func == (lhs: RoutineList.Row, rhs: RoutineList.Row) -> Bool {
    lhs.type == rhs.type
  }
}
