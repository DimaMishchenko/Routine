import Foundation
import UIKit.UIImage

struct ValueCellVM: Hashable {
  let title: String
  let value: ValueType?
  let icon: UIImage?
  let accessory: Accessory
  
  init(
    title: String,
    value: ValueType? = nil,
    icon: UIImage? = nil,
    accessory: Accessory = .none
  ) {
    self.title = title
    self.value = value
    self.icon = icon
    self.accessory = accessory
  }
}

// MARK: - ValueStyle
extension ValueCellVM {
  enum ValueType: Hashable {
    case text(String?, style: TextValueStyle = .default)
    case emoji(String?)
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
