import Foundation
import UIKit.UIImage

struct PickerCellVM<Value: Hashable>: Hashable {
  let title: String
  let values: [Value]
  let selected: Value
  let icon: UIImage?
  let style: PickerStyle
  
  init(
    title: String,
    values: [Value],
    selected: Value,
    icon: UIImage? = nil,
    style: PickerStyle
  ) {
    self.title = title
    self.values = values
    self.selected = selected
    self.icon = icon
    self.style = style
  }
}

// MARK: - PickerStyle
extension PickerCellVM {
  enum PickerStyle: Hashable {
    case wheel
    case menu
  }
}
