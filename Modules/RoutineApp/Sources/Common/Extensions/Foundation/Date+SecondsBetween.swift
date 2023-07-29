import Foundation

extension Date {
  func secondsBetween(_ date: Date) -> Int? {
    Calendar.app.dateComponents([.second], from: self, to: date).second
  }
}
