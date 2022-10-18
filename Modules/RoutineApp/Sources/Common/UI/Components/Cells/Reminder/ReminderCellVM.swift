import Foundation

struct ReminderCellVM: Hashable {
  private let uuid: String
  let title: String
  let date: Date
  
  init(
    uuid: String,
    title: String,
    date: Date
  ) {
    self.uuid = uuid
    self.title = title
    self.date = date
  }
}
