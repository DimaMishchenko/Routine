import Foundation

extension Date {
  func daysBetween(_ date: Date) -> Int? {
    Calendar.current.dateComponents([.day], from: self, to: date).day
  }
}
