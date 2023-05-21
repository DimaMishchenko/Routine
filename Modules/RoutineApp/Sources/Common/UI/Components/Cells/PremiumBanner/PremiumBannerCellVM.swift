import Foundation

struct PremiumBannerCellVM: Hashable {
  enum Accesory: Hashable {
    case close
    case disclosure
  }
  
  private let uuid = UUID()
  let accesory: Accesory
  
  init(accesory: Accesory) {
    self.accesory = accesory
  }
}
