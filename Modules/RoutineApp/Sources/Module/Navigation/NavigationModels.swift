import Foundation
import UIKit.UIImage

enum Navigation {
  enum ItemType: Hashable, Equatable {
    case home
    case settings
  }
  
  struct ItemVM: Hashable, Equatable {
    let type: ItemType
    let title: String
    let image: UIImage
    let selectedImage: UIImage
  }
}
