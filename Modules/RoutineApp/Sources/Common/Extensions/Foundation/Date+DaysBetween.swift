import Foundation

extension Date {
  func daysBetween(_ date: Date) -> Int? {
    Calendar.app.dateComponents([.day], from: self, to: date).day
  }
}
