import Foundation

enum TabBar {
  enum ItemType {
    case home
    case settings
  }
  
  struct ItemVM {
    let type: ItemType
    let title: String
  }
}
