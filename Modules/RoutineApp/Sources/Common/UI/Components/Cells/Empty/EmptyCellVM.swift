import Foundation

struct EmptyCellVM: Hashable {
  private let uuid = UUID()
  let text: String
  
  init(text: String) {
    self.text = text
  }
}
