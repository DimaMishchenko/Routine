import Foundation

struct ReminderCellVM: Hashable {
  private let uuid: String
  let title: String
  let value: String
  
  init(
    uuid: String,
    title: String,
    value: String
  ) {
    self.uuid = uuid
    self.title = title
    self.value = value
  }
}
