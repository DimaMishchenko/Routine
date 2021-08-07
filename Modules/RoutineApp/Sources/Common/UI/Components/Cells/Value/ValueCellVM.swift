import Foundation

struct ValueCellVM: Hashable {
  let title: String
  let value: String?
  let valueStyle: ValueStyle
  let accessory: Accessory
  
  init(
    title: String,
    value: String? = nil,
    valueStyle: ValueStyle = .default,
    accessory: Accessory = .none
  ) {
    self.title = title
    self.value = value
    self.valueStyle = valueStyle
    self.accessory = accessory
  }
}

// MARK: - ValueStyle
extension ValueCellVM {
  enum ValueStyle {
    case `default`
    case bold
  }
}

// MARK: - Accessory
extension ValueCellVM {
  enum Accessory {
    case none
    case disclosure
  }
}
