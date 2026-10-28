import Foundation

enum Settings {
  struct Section: Hashable {
    let model: GroupSupplementaryVM
    let footer: String?

    init(model: GroupSupplementaryVM, footer: String? = nil) {
      self.model = model
      self.footer = footer
    }
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
    case value(ValueCellVM)
    case `switch`(SwitchCellVM, SwitchType)
  }
  
  enum SwitchType {
    case notifications
    case faceID
  }
}
extension Settings.Row: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(type)
  }
  
  static func == (lhs: Settings.Row, rhs: Settings.Row) -> Bool {
    lhs.type == rhs.type
  }
}
