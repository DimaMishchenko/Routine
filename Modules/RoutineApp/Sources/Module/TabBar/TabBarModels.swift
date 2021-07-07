import Foundation
import SFSafeSymbols

enum TabBar {
  enum ItemType {
    case routines
    case settings
  }
  
  struct ItemVM {
    let type: ItemType
    let title: String
    let sfSymbol: SFSymbol
  }
}
