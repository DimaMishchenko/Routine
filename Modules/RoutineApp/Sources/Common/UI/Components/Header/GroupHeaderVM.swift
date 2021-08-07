import Foundation

struct GroupHeaderVM: Hashable {
  let title: String
  let accessory: Accessory
  
  init(
    title: String,
    accessory: Accessory = .none
  ) {
    self.title = title
    self.accessory = accessory
  }
}

// MARK: - Accessory
extension GroupHeaderVM {
  enum Accessory {
    case none
    case outlineDisclosure
  }
}
