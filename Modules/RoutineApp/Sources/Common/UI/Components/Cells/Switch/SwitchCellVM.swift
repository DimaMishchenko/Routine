import Foundation
import UIKit.UIImage

struct SwitchCellVM: Hashable {
  let title: String
  let state: Bool
  let icon: UIImage?
  
  init(
    title: String,
    state: Bool,
    icon: UIImage? = nil
  ) {
    self.title = title
    self.state = state
    self.icon = icon
  }
}
