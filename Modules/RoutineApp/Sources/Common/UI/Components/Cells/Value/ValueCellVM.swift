import Foundation

struct ValueCellVM: Hashable {
  let title: String
  let value: ValueType?
  let accessory: Accessory
  
  init(
    title: String,
    value: ValueType? = nil,
    accessory: Accessory = .none
  ) {
    self.title = title
    self.value = value
    self.accessory = accessory
  }
}

// MARK: - ValueStyle
extension ValueCellVM {
  enum ValueType: Hashable {
    case text(String?, style: TextValueStyle = .default)
    case emoji(String?)
    case color(hex: String?)
  }
}

// MARK: - ValueStyle
extension ValueCellVM {
  enum TextValueStyle: Hashable {
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
