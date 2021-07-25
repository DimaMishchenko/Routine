import Foundation

enum Settings {
  // MARK: - Section
  struct Section: Hashable {
    let title: String
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
    case disclousre(ValueCellVM)
  }
}

// MARK: - Cell+Hashable
extension Settings.Row: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(type)
  }
  
  static func == (lhs: Settings.Row, rhs: Settings.Row) -> Bool {
    lhs.type == rhs.type
  }
}
